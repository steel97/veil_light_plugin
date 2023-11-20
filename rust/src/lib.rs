#![deny(clippy::all)]
#![deny(clippy::pedantic)]
//#![no_std]

extern crate byteorder;

// 1.2.7
use byteorder::ByteOrder;
use rand::{RngCore, SeedableRng};
use rand_hc::Hc128Rng;
extern crate secp256k1_sys;

//#[cfg(not(target_arch = "wasm32"))]
//compile_error!("Only `wasm32` target_arch is supported.");

//#[cfg(target_arch = "wasm32")]
/*#[panic_handler]
fn panic_handler(_info: &core::panic::PanicInfo) -> ! {
    //core::arch::wasm32::unreachable()
}*/

use secp256k1_sys::{
    secp256k1_context_no_precomp,
    secp256k1_context_preallocated_create,
    secp256k1_context_preallocated_size,
    secp256k1_context_randomize,
    secp256k1_ec_pubkey_combine,
    secp256k1_ec_pubkey_create,
    secp256k1_ec_pubkey_parse,
    secp256k1_ec_pubkey_serialize,
    secp256k1_ec_pubkey_tweak_add,
    secp256k1_ec_pubkey_tweak_add_raw,
    secp256k1_ec_pubkey_tweak_mul,
    secp256k1_ec_seckey_negate,
    secp256k1_ec_seckey_tweak_add,
    // veil
    secp256k1_ec_seckey_verify,
    secp256k1_ecdh_veil,
    secp256k1_ecdsa_sign,
    secp256k1_ecdsa_signature_normalize,
    secp256k1_ecdsa_signature_parse_compact,
    secp256k1_ecdsa_signature_serialize_compact,
    secp256k1_ecdsa_verify,
    secp256k1_generate_mlsag,
    secp256k1_get_keyimage,
    secp256k1_keypair_create,
    secp256k1_keypair_xonly_pub,
    secp256k1_nonce_function_bip340,
    secp256k1_nonce_function_rfc6979,
    secp256k1_pedersen_blind_sum,
    secp256k1_pedersen_commit,
    secp256k1_prepare_mlsag,
    secp256k1_rangeproof_rewind,
    secp256k1_rangeproof_sign,
    secp256k1_rangeproof_verify,

    secp256k1_schnorrsig_sign,
    secp256k1_schnorrsig_verify,
    secp256k1_verify_mlsag,
    secp256k1_xonly_pubkey_from_pubkey,
    secp256k1_xonly_pubkey_parse,
    secp256k1_xonly_pubkey_serialize,
    secp256k1_xonly_pubkey_tweak_add,
    secp256k1_xonly_pubkey_tweak_add_check,
    types::c_void,
    Context,
    KeyPair,
    PublicKey,
    Signature,
    XOnlyPublicKey,
    SECP256K1_SER_COMPRESSED,
    SECP256K1_SER_UNCOMPRESSED,
    SECP256K1_START_SIGN,
    SECP256K1_START_VERIFY,
};

use secp256k1_sys::recovery::{
    secp256k1_ecdsa_recover, secp256k1_ecdsa_recoverable_signature_parse_compact,
    secp256k1_ecdsa_recoverable_signature_serialize_compact, secp256k1_ecdsa_sign_recoverable,
    RecoverableSignature,
};

/*#[link(wasm_import_module = "./validate_error.js")]
extern "C" {
    #[link_name = "throwError"]
    fn throw_error(errcode: usize);
}*/

fn throw_error(errcode: usize) {
    panic!("{}", errcode);
}

/*#[link(wasm_import_module = "./rand.js")]
extern "C" {
    #[link_name = "generateInt32"]
    fn generate_int32() -> i32;

    #[link_name = "printn"]
    fn printn(msg: u8);
    #[link_name = "printn"]
    fn printn2(msg: usize);
    #[link_name = "printn"]
    fn printn3(msg: u64);
    #[link_name = "printn"]
    fn printn4(msg: u32);
}*/

type InvalidInputResult<T> = Result<T, usize>;

#[allow(clippy::large_stack_arrays)]
static mut CONTEXT_BUFFER: [u8; 1_114_336] = [0; 1_114_336];
//static CONTEXT_BUFFER: [u8; 1_114_320] = [0; 1_114_320];
//static CONTEXT_BUFFER: [u8; 1_114_336] = [0; 1_114_336];
static mut CONTEXT_SEED: [u8; 32] = [0; 32];

const PRIVATE_KEY_SIZE: usize = 32;
const PUBLIC_KEY_COMPRESSED_SIZE: usize = 33;
const PUBLIC_KEY_UNCOMPRESSED_SIZE: usize = 65;
const X_ONLY_PUBLIC_KEY_SIZE: usize = 32;
const TWEAK_SIZE: usize = 32;
const HASH_SIZE: usize = 32;
const EXTRA_DATA_SIZE: usize = 32;
const SIGNATURE_SIZE: usize = 64;

const ERROR_BAD_PRIVATE: usize = 0;
const ERROR_BAD_POINT: usize = 1;
// const ERROR_BAD_TWEAK: usize = 2;
// const ERROR_BAD_HASH: usize = 3;
const ERROR_BAD_SIGNATURE: usize = 4;
// const ERROR_BAD_EXTRA_DATA: usize = 5;
// const ERROR_BAD_PARITY: usize = 6;
const MESSAGE_SIZE: usize = 256;
const PROOF_SIZE: usize = 40960;

const WTF_MERGED_ARRAY_SIZE: usize = 1_048_576;

#[no_mangle]
pub static mut MYTEST_INTGR: u32 = 1337;
#[no_mangle]
pub static mut MYTEST_ARRAY: [u8; 5] = [97, 112, 112, 108, 101];

#[no_mangle]
pub static mut PRIVATE_INPUT: [u8; PRIVATE_KEY_SIZE] = [0; PRIVATE_KEY_SIZE];
#[no_mangle]
pub static mut PUBLIC_KEY_INPUT: [u8; PUBLIC_KEY_UNCOMPRESSED_SIZE] =
    [0; PUBLIC_KEY_UNCOMPRESSED_SIZE];
#[no_mangle]
pub static PUBLIC_KEY_INPUT2: [u8; PUBLIC_KEY_UNCOMPRESSED_SIZE] =
    [0; PUBLIC_KEY_UNCOMPRESSED_SIZE];
#[no_mangle]
pub static mut X_ONLY_PUBLIC_KEY_INPUT: [u8; X_ONLY_PUBLIC_KEY_SIZE] = [0; X_ONLY_PUBLIC_KEY_SIZE];
#[no_mangle]
pub static mut X_ONLY_PUBLIC_KEY_INPUT2: [u8; X_ONLY_PUBLIC_KEY_SIZE] = [0; X_ONLY_PUBLIC_KEY_SIZE];
#[no_mangle]
pub static mut TWEAK_INPUT: [u8; TWEAK_SIZE] = [0; TWEAK_SIZE];
#[no_mangle]
pub static HASH_INPUT: [u8; HASH_SIZE] = [0; HASH_SIZE];
#[no_mangle]
pub static EXTRA_DATA_INPUT: [u8; EXTRA_DATA_SIZE] = [0; EXTRA_DATA_SIZE];
#[no_mangle]
pub static mut SIGNATURE_INPUT: [u8; SIGNATURE_SIZE] = [0; SIGNATURE_SIZE];

// veil start
#[no_mangle]
pub static mut KI_OUTPUT: [u8; PUBLIC_KEY_COMPRESSED_SIZE] = [0; PUBLIC_KEY_COMPRESSED_SIZE];
#[no_mangle]
pub static mut PK_INPUT: [u8; PUBLIC_KEY_COMPRESSED_SIZE] = [0; PUBLIC_KEY_COMPRESSED_SIZE];
#[no_mangle]
pub static mut SK_INPUT: [u8; PUBLIC_KEY_COMPRESSED_SIZE] = [0; PUBLIC_KEY_COMPRESSED_SIZE];

#[no_mangle]
pub static mut BLIND_OUTPUT: [u8; PRIVATE_KEY_SIZE] = [0; PRIVATE_KEY_SIZE];
#[no_mangle]
pub static mut MESSAGE_OUTPUT: [u8; MESSAGE_SIZE] = [0; MESSAGE_SIZE];
#[no_mangle]
pub static mut NONCE_OUTPUT: [u8; PRIVATE_KEY_SIZE] = [0; PRIVATE_KEY_SIZE];
#[no_mangle]
pub static mut COMMIT: [u8; PUBLIC_KEY_COMPRESSED_SIZE] = [0; PUBLIC_KEY_COMPRESSED_SIZE];
#[no_mangle]
pub static mut PROOF: [u8; PROOF_SIZE] = [0; PROOF_SIZE];
#[no_mangle]
pub static mut PROOFRESULT: [u8; 40] = [0; 40];

// BLINDS - big array
#[no_mangle]
pub static mut BLINDS: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// M_INPUT - big array
#[no_mangle]
pub static mut M_INPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PCM_IN - big array
#[no_mangle]
pub static mut PCM_IN: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PCM_OUT - big array
#[no_mangle]
pub static mut PCM_OUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// KI_BIG_OUTPUT - big array
#[no_mangle]
pub static mut KI_BIG_OUTPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PC_OUTPUT - big array
#[no_mangle]
pub static mut PC_OUTPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PS_OUTPUT - big array
#[no_mangle]
pub static mut PS_OUTPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PREIMAGE_INPUT - 32 bytes,
#[no_mangle]
pub static mut PREIMAGE_INPUT: [u8; 32] = [0; 32];
// SKS_INPUT - big array
#[no_mangle]
pub static mut SKS_INPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// PKS_INPUT - big array
#[no_mangle]
pub static mut PKS_INPUT: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// veil end

// workaround alloc
// SKS_INPUT - big array
#[no_mangle]
pub static mut EBUF1: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
#[no_mangle]
pub static mut EBUF2: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
#[no_mangle]
pub static mut EBUF3: [u8; WTF_MERGED_ARRAY_SIZE] = [0; WTF_MERGED_ARRAY_SIZE];
// end

macro_rules! jstry {
    ($value:expr) => {
        jstry!($value, ())
    };
    ($value:expr, $ret:expr) => {
        match $value {
            Ok(value) => value,
            Err(code) => {
                throw_error(code);
                return $ret;
            }
        }
    };
}

fn initialize_context_seed() {
    unsafe {
        for offset in (0..8).map(|v| v * 4) {
            let mut rng = Hc128Rng::from_entropy();
            let value: u32 = rng.next_u32();
            let bytes: [u8; 4] = value.to_ne_bytes();
            CONTEXT_SEED[offset..offset + 4].copy_from_slice(&bytes);
        }
    }
}

fn get_context() -> *const Context {
    static mut CONTEXT: *const Context = core::ptr::null();
    unsafe {
        if CONTEXT_SEED[0] == 0 {
            let size =
                secp256k1_context_preallocated_size(SECP256K1_START_SIGN | SECP256K1_START_VERIFY);
            assert_eq!(size, CONTEXT_BUFFER.len());
            let ctx = secp256k1_context_preallocated_create(
                CONTEXT_BUFFER.as_ptr() as *mut c_void,
                SECP256K1_START_SIGN | SECP256K1_START_VERIFY,
            );
            initialize_context_seed();
            let retcode = secp256k1_context_randomize(ctx, CONTEXT_SEED.as_ptr());
            CONTEXT_SEED[0] = 1;
            CONTEXT_SEED[1..].fill(0);
            assert_eq!(retcode, 1);
            CONTEXT = ctx;
        }
        CONTEXT
    }
}

unsafe fn create_keypair(input: *const u8) -> InvalidInputResult<KeyPair> {
    let mut kp = KeyPair::new();
    if secp256k1_keypair_create(get_context(), &mut kp, input) == 1 {
        Ok(kp)
    } else {
        Err(ERROR_BAD_PRIVATE)
    }
}

unsafe fn x_only_pubkey_from_pubkey(input: *const u8, inputlen: usize) -> (XOnlyPublicKey, i32) {
    let mut xonly_pk = XOnlyPublicKey::new();
    let mut parity: i32 = 0;
    let pubkey = jstry!(pubkey_parse(input, inputlen), (xonly_pk, parity));
    x_only_pubkey_from_pubkey_struct(&mut xonly_pk, &mut parity, &pubkey)
}

unsafe fn x_only_pubkey_from_pubkey_struct(
    xonly_pk: &mut XOnlyPublicKey,
    parity: &mut i32,
    pubkey: &PublicKey,
) -> (XOnlyPublicKey, i32) {
    assert_eq!(
        secp256k1_xonly_pubkey_from_pubkey(get_context(), xonly_pk, parity, pubkey),
        1
    );
    (*xonly_pk, *parity)
}

unsafe fn pubkey_parse(input: *const u8, inputlen: usize) -> InvalidInputResult<PublicKey> {
    let mut pk = PublicKey::new();
    if secp256k1_ec_pubkey_parse(secp256k1_context_no_precomp, &mut pk, input, inputlen) == 1 {
        Ok(pk)
    } else {
        Err(ERROR_BAD_POINT)
    }
}

unsafe fn x_only_pubkey_parse(input: *const u8) -> InvalidInputResult<XOnlyPublicKey> {
    let mut pk = XOnlyPublicKey::new();
    if secp256k1_xonly_pubkey_parse(secp256k1_context_no_precomp, &mut pk, input) == 1 {
        Ok(pk)
    } else {
        Err(ERROR_BAD_POINT)
    }
}

unsafe fn pubkey_serialize(pk: &PublicKey, output: *mut u8, mut outputlen: usize) {
    let flags = if outputlen == PUBLIC_KEY_COMPRESSED_SIZE {
        SECP256K1_SER_COMPRESSED
    } else {
        SECP256K1_SER_UNCOMPRESSED
    };
    assert_eq!(
        secp256k1_ec_pubkey_serialize(
            secp256k1_context_no_precomp,
            output,
            &mut outputlen,
            pk.as_ptr().cast::<PublicKey>(),
            flags,
        ),
        1
    );
}

unsafe fn x_only_pubkey_serialize(pk: &XOnlyPublicKey, output: *mut u8) {
    assert_eq!(
        secp256k1_xonly_pubkey_serialize(
            secp256k1_context_no_precomp,
            output,
            pk.as_ptr().cast::<XOnlyPublicKey>(),
        ),
        1
    );
}

#[no_mangle]
#[export_name = "initializeContext"]
pub extern "C" fn initialize_context() {
    get_context();
}

#[no_mangle]
#[export_name = "isPoint"]
pub extern "C" fn is_point(inputlen: usize) -> usize {
    unsafe {
        if inputlen == X_ONLY_PUBLIC_KEY_SIZE {
            x_only_pubkey_parse(PUBLIC_KEY_INPUT.as_ptr()).map_or_else(|_error| 0, |_pk| 1)
        } else {
            pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen).map_or_else(|_error| 0, |_pk| 1)
        }
    }
}

// We know (ptrs.len() as i32) will not trunc or wrap since it is always 2.
#[allow(clippy::cast_possible_truncation)]
#[allow(clippy::cast_possible_wrap)]
#[no_mangle]
#[export_name = "pointAdd"]
pub extern "C" fn point_add(inputlen: usize, inputlen2: usize, outputlen: usize) -> i32 {
    unsafe {
        let pk1 = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        let pk2 = jstry!(pubkey_parse(PUBLIC_KEY_INPUT2.as_ptr(), inputlen2), 0);
        let mut pk = PublicKey::new();
        let ptrs = [pk1.as_ptr(), pk2.as_ptr()];
        if secp256k1_ec_pubkey_combine(
            secp256k1_context_no_precomp,
            &mut pk,
            ptrs.as_ptr().cast::<*const PublicKey>(),
            ptrs.len() as i32,
        ) == 1
        {
            pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "pointAddScalar"]
pub extern "C" fn point_add_scalar(inputlen: usize, outputlen: usize) -> i32 {
    unsafe {
        let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        if secp256k1_ec_pubkey_tweak_add(
            get_context(),
            pk.as_mut_ptr().cast::<PublicKey>(),
            TWEAK_INPUT.as_ptr(),
        ) == 1
        {
            pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "xOnlyPointAddTweak"]
pub extern "C" fn x_only_point_add_tweak() -> i32 {
    unsafe {
        let mut xonly_pk = jstry!(x_only_pubkey_parse(X_ONLY_PUBLIC_KEY_INPUT.as_ptr()), 0);
        let mut pubkey = PublicKey::new();
        if secp256k1_xonly_pubkey_tweak_add(
            get_context(),
            &mut pubkey,
            &xonly_pk,
            TWEAK_INPUT.as_ptr(),
        ) != 1
        {
            // infinity point
            return -1;
        }
        let mut parity: i32 = 0;
        x_only_pubkey_from_pubkey_struct(&mut xonly_pk, &mut parity, &pubkey);
        x_only_pubkey_serialize(&xonly_pk, X_ONLY_PUBLIC_KEY_INPUT.as_mut_ptr());
        parity
    }
}

#[no_mangle]
#[export_name = "xOnlyPointAddTweakCheck"]
pub extern "C" fn x_only_point_add_tweak_check(tweaked_parity: i32) -> i32 {
    unsafe {
        let xonly_pk = jstry!(x_only_pubkey_parse(X_ONLY_PUBLIC_KEY_INPUT.as_ptr()), 0);
        let tweaked_key_ptr = X_ONLY_PUBLIC_KEY_INPUT2.as_ptr();
        jstry!(x_only_pubkey_parse(tweaked_key_ptr), 0);

        secp256k1_xonly_pubkey_tweak_add_check(
            get_context(),
            tweaked_key_ptr,
            tweaked_parity,
            &xonly_pk,
            TWEAK_INPUT.as_ptr(),
        )
    }
}

#[no_mangle]
#[export_name = "pointCompress"]
pub extern "C" fn point_compress(inputlen: usize, outputlen: usize) {
    unsafe {
        let pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen));
        pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
    }
}

#[no_mangle]
#[export_name = "pointFromScalar"]
pub extern "C" fn point_from_scalar(outputlen: usize) -> i32 {
    unsafe {
        let mut pk = PublicKey::new();
        if secp256k1_ec_pubkey_create(get_context(), &mut pk, PRIVATE_INPUT.as_ptr()) == 1 {
            pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
#[export_name = "xOnlyPointFromScalar"]
pub extern "C" fn x_only_point_from_scalar() -> i32 {
    unsafe {
        let keypair = jstry!(create_keypair(PRIVATE_INPUT.as_ptr()), 0);
        let mut xonly_pk = XOnlyPublicKey::new();
        let mut parity: i32 = 0; // TODO: Should we return this somehow?
        assert_eq!(
            secp256k1_keypair_xonly_pub(get_context(), &mut xonly_pk, &mut parity, &keypair),
            1
        );
        x_only_pubkey_serialize(&xonly_pk, X_ONLY_PUBLIC_KEY_INPUT.as_mut_ptr());
        1
    }
}

#[no_mangle]
#[export_name = "xOnlyPointFromPoint"]
pub extern "C" fn x_only_point_from_point(inputlen: usize) -> i32 {
    unsafe {
        let (xonly_pk, _parity) = x_only_pubkey_from_pubkey(PUBLIC_KEY_INPUT.as_ptr(), inputlen);
        x_only_pubkey_serialize(&xonly_pk, X_ONLY_PUBLIC_KEY_INPUT.as_mut_ptr());
        1
    }
}

#[no_mangle]
#[export_name = "pointMultiply"]
pub extern "C" fn point_multiply(inputlen: usize, outputlen: usize) -> i32 {
    unsafe {
        let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        if secp256k1_ec_pubkey_tweak_mul(get_context(), &mut pk, TWEAK_INPUT.as_ptr()) == 1 {
            pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "privateAdd"]
pub extern "C" fn private_add() -> i32 {
    unsafe {
        if secp256k1_ec_seckey_tweak_add(
            secp256k1_context_no_precomp,
            PRIVATE_INPUT.as_mut_ptr(),
            TWEAK_INPUT.as_ptr(),
        ) == 1
        {
            1
        } else {
            0
        }
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
#[export_name = "privateSub"]
pub extern "C" fn private_sub() -> i32 {
    unsafe {
        assert_eq!(
            secp256k1_ec_seckey_negate(secp256k1_context_no_precomp, TWEAK_INPUT.as_mut_ptr()),
            1
        );
        if secp256k1_ec_seckey_tweak_add(
            secp256k1_context_no_precomp,
            PRIVATE_INPUT.as_mut_ptr(),
            TWEAK_INPUT.as_ptr(),
        ) == 1
        {
            1
        } else {
            0
        }
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
#[export_name = "privateNegate"]
pub extern "C" fn private_negate() {
    unsafe {
        assert_eq!(
            secp256k1_ec_seckey_negate(secp256k1_context_no_precomp, PRIVATE_INPUT.as_mut_ptr()),
            1
        );
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
pub extern "C" fn sign(extra_data: i32) {
    unsafe {
        let mut sig = Signature::new();
        let noncedata = if extra_data == 0 {
            core::ptr::null()
        } else {
            EXTRA_DATA_INPUT.as_ptr()
        }
        .cast::<c_void>();

        assert_eq!(
            secp256k1_ecdsa_sign(
                get_context(),
                &mut sig,
                HASH_INPUT.as_ptr(),
                PRIVATE_INPUT.as_ptr(),
                secp256k1_nonce_function_rfc6979,
                noncedata
            ),
            1
        );

        assert_eq!(
            secp256k1_ecdsa_signature_serialize_compact(
                secp256k1_context_no_precomp,
                SIGNATURE_INPUT.as_mut_ptr(),
                &sig,
            ),
            1
        );
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
#[export_name = "signRecoverable"]
pub extern "C" fn sign_recoverable(extra_data: i32) -> i32 {
    unsafe {
        let mut sig = RecoverableSignature::new();
        let noncedata = if extra_data == 0 {
            core::ptr::null()
        } else {
            EXTRA_DATA_INPUT.as_ptr()
        }
        .cast::<c_void>();

        assert_eq!(
            secp256k1_ecdsa_sign_recoverable(
                get_context(),
                &mut sig,
                HASH_INPUT.as_ptr(),
                PRIVATE_INPUT.as_ptr(),
                secp256k1_nonce_function_rfc6979,
                noncedata
            ),
            1
        );

        let mut recid: i32 = 0;
        secp256k1_ecdsa_recoverable_signature_serialize_compact(
            secp256k1_context_no_precomp,
            SIGNATURE_INPUT.as_mut_ptr(),
            &mut recid,
            &sig,
        );
        recid
    }
}

#[allow(clippy::missing_panics_doc)]
#[no_mangle]
#[export_name = "signSchnorr"]
pub extern "C" fn sign_schnorr(extra_data: i32) {
    unsafe {
        let mut keypair = KeyPair::new();
        let noncedata = if extra_data == 0 {
            core::ptr::null()
        } else {
            EXTRA_DATA_INPUT.as_ptr()
        }
        .cast::<c_void>();

        assert_eq!(
            secp256k1_keypair_create(get_context(), &mut keypair, PRIVATE_INPUT.as_ptr()),
            1
        );

        /*

        cx: *const Context,
        sig: *mut c_uchar,
        msg32: *const c_uchar,
        keypair: *const KeyPair,
        aux_rand32: *const c_uchar
        */
        assert_eq!(
            secp256k1_schnorrsig_sign(
                get_context(),
                SIGNATURE_INPUT.as_mut_ptr(),
                HASH_INPUT.as_ptr(),
                &keypair,
                secp256k1_nonce_function_bip340,
                noncedata
            ),
            1
        );
    }
}

#[no_mangle]
pub extern "C" fn verify(inputlen: usize, strict: i32) -> i32 {
    unsafe {
        let pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);

        let mut signature = Signature::new();
        if secp256k1_ecdsa_signature_parse_compact(
            secp256k1_context_no_precomp,
            &mut signature,
            SIGNATURE_INPUT.as_ptr(),
        ) == 0
        {
            throw_error(ERROR_BAD_SIGNATURE);
            return 0;
        }

        if strict == 0 {
            secp256k1_ecdsa_signature_normalize(
                secp256k1_context_no_precomp,
                &mut signature,
                &signature,
            );
        }

        if secp256k1_ecdsa_verify(get_context(), &signature, HASH_INPUT.as_ptr(), &pk) == 1 {
            1
        } else {
            0
        }
    }
}

#[no_mangle]
pub extern "C" fn recover(outputlen: usize, recid: i32) -> i32 {
    unsafe {
        let mut signature = RecoverableSignature::new();
        if secp256k1_ecdsa_recoverable_signature_parse_compact(
            secp256k1_context_no_precomp,
            &mut signature,
            SIGNATURE_INPUT.as_ptr(),
            recid,
        ) == 0
        {
            throw_error(ERROR_BAD_SIGNATURE);
            return 0;
        }

        let mut pk = PublicKey::new();
        if secp256k1_ecdsa_recover(get_context(), &mut pk, &signature, HASH_INPUT.as_ptr()) == 1 {
            pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "verifySchnorr"]
pub extern "C" fn verify_schnorr() -> i32 {
    /*

    cx: *const Context,
        sig64: *const c_uchar,
        msg32: *const c_uchar,
        msglen: size_t,
        pubkey: *const XOnlyPublicKey,
    */
    unsafe {
        let pk = jstry!(x_only_pubkey_parse(X_ONLY_PUBLIC_KEY_INPUT.as_ptr()), 0);
        if secp256k1_schnorrsig_verify(
            get_context(),
            SIGNATURE_INPUT.as_ptr(),
            HASH_INPUT.as_ptr(),
            &pk,
        ) == 1
        {
            1
        } else {
            0
        }
    }
}

// veil
// secp256k1_get_keyimage
#[no_mangle]
#[export_name = "getKeyImage"]
pub extern "C" fn get_keyimage(_outputlen: usize, _inputpk_len: usize, _inputsk_len: usize) -> i32 {
    /*

        cx: *const Context,
        ki: *mut c_uchar,     // output
        pk: *const PublicKey, // pk1
        sk: *const c_uchar,   // pk2
    */
    unsafe {
        //let pk2 = jstry!(pubkey_parse(PK_INPUT.as_ptr(), inputpkLen), 0);
        /*for i in 0..33 {
            printn(PK_INPUT[i]);
        }*/
        if secp256k1_get_keyimage(
            get_context(),
            KI_OUTPUT.as_mut_ptr(), //&mut pk
            PK_INPUT.as_mut_ptr(),
            SK_INPUT.as_mut_ptr(),
        ) == 1
        {
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "rangeProofRewind"]
pub extern "C" fn rangeproof_rewind(mut outlen: usize, plen: usize) -> i32 {
    // mut outputlen: usize
    /*
        cx: *const Context,
        blind_out: *mut c_uchar,
        value_out:  *mut size_t,//longlong
        message_out:  *mut c_uchar,
        outlen: *mut size_t,
        nonce:  *mut c_uchar,
        min_value:  *mut size_t, //longlong
        max_value:  *mut size_t, // longlong
        commit: *mut c_uchar, // rustsecp256k1_v0_4_1_pedersen_commitment
        proof: *mut c_uchar,
        plen: size_t, // without * usize
        extra_commit: *mut c_uchar, ptr::null()
        extra_commit_len: size_t, //without *  usize
    */
    unsafe {
        let mut value_out: u64 = 0;
        let mut min_value: u64 = 0;
        let mut max_value: u64 = 0;
        //let pk2 = jstry!(pubkey_parse(PK_INPUT.as_ptr(), inputpkLen), 0);
        /*for i in 0..33 {
            printn(PK_INPUT[i]);
        }*/
        let res = secp256k1_rangeproof_rewind(
            get_context(),
            BLIND_OUTPUT.as_mut_ptr(),
            &mut value_out,
            MESSAGE_OUTPUT.as_mut_ptr(),
            &mut outlen,
            NONCE_OUTPUT.as_mut_ptr(),
            &mut min_value,
            &mut max_value,
            COMMIT.as_mut_ptr(),
            PROOF.as_mut_ptr(),
            plen,
            BLIND_OUTPUT.as_mut_ptr(), //tempory, should be nullptr
            0,
        );
        if res == 1 {
            //let mut a = value_out as u64;
            //let mut b = value_out;
            //printn3(a);
            //printn2(b);
            byteorder::NativeEndian::write_u64(&mut PROOFRESULT[0..0 + 8], value_out as u64);
            byteorder::NativeEndian::write_u64(&mut PROOFRESULT[8..8 + 8], outlen as u64);
            byteorder::NativeEndian::write_u64(&mut PROOFRESULT[16..16 + 8], min_value as u64);
            byteorder::NativeEndian::write_u64(&mut PROOFRESULT[24..24 + 8], max_value as u64);
        }

        if res == 1 {
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "rangeProofVerify"]
pub extern "C" fn rangeproof_verify(_outlen: usize, plen: usize) -> i32 {
    // mut outputlen: usize
    unsafe {
        //let mut value_out: u64 = 0;
        let mut min_value: u64 = 0;
        let mut max_value: u64 = 0;
        //let pk2 = jstry!(pubkey_parse(PK_INPUT.as_ptr(), inputpkLen), 0);
        /*for i in 0..33 {
            printn(PK_INPUT[i]);
        }*/
        let res = secp256k1_rangeproof_verify(
            get_context(),
            &mut min_value,
            &mut max_value,
            COMMIT.as_mut_ptr(),
            PROOF.as_mut_ptr(),
            plen,
            BLIND_OUTPUT.as_mut_ptr(), //tempory, should be nullptr
            0,
        );
        res
    }
}

//secp256k1_ecdh_veil
#[no_mangle]
#[export_name = "ECDH_VEIL"]
pub extern "C" fn ecdh_veil(inputlen: usize) -> i32 {
    unsafe {
        let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        return secp256k1_ecdh_veil(
            get_context(),
            NONCE_OUTPUT.as_mut_ptr(),
            pk.as_mut_ptr().cast::<PublicKey>(),
            PRIVATE_INPUT.as_ptr(),
        );
    }
}

//secp256k1_pedersen_commit
#[no_mangle]
#[export_name = "pedersenCommit"]
pub extern "C" fn pedersen_commit(value: u64) -> i32 {
    unsafe {
        /*
        commit: *mut c_uchar,
        blind: *mut c_uchar,
        value: *mut u64,//longlong
        */
        //let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        return secp256k1_pedersen_commit(
            get_context(),
            COMMIT.as_mut_ptr(),
            BLIND_OUTPUT.as_mut_ptr(),
            value,
        );
    }
}

//secp256k1_rangeproof_sign
#[no_mangle]
#[export_name = "rangeproofSign"]
pub extern "C" fn rangeproof_sign(
    mut plen: u32,
    min_value: u64,
    exp: i32,
    min_bits: i32,
    value: u64,
    msg_len: usize,
) -> i32 {
    println!("calling rangeproof sign"); // do not remove, for some reason without it app crashes on android (something with std?)
    unsafe {
        /*
        proof: *mut c_uchar,
        plen: *mut size_t,
        min_value: u64,
        commit: *mut c_uchar,
        blind: *mut c_uchar,
        nonce: *mut c_uchar,
        exp: c_int,
        min_bits: c_int,
        value: u64,//longlong
        message: *mut c_uchar,
        msg_len: size_t,
        extra_commit: *mut c_uchar,
        extra_commit_len: size_t
        */
        let res = secp256k1_rangeproof_sign(
            get_context(),
            PROOF.as_mut_ptr(),
            &mut plen,
            min_value,
            COMMIT.as_mut_ptr(),
            BLIND_OUTPUT.as_mut_ptr(),
            NONCE_OUTPUT.as_mut_ptr(),
            exp,
            min_bits,
            value,
            MESSAGE_OUTPUT.as_mut_ptr(),
            msg_len,
            BLIND_OUTPUT.as_mut_ptr(), //tempory, should be nullptr
            0,
        );
        if res > 0 {
            //printn4(plen);
            byteorder::NativeEndian::write_u32(&mut PRIVATE_INPUT[0..0 + 4], plen);
            //plen as i32
            1
        } else {
            0
        }
    }
}

//
//
//
// 4 LEFT METHODS
//
//
//

// new buffers

// BLINDS - big array
// M_INPUT - big array
// PCM_IN - big array
// PCM_OUT - big array
// KI_OUTPUT - big array
// PC_OUTPUT - big array
// PS_OUTPUT - big array
// PREIMAGE_INPUT - 32 bytes,
// SKS_INPUT - big array
// PKS_INPUT - big array

// end

//secp256k1_pedersen_blind_sum
//cx, unsigned char *blind_out, blinds_size, const unsigned char *const *blinds, size_t n, size_t npositive
//blind_out (return), blinds (const),
#[no_mangle]
#[export_name = "pedersenBlindSum"]
pub extern "C" fn pedersen_blind_sum(blinds_size: usize, n: usize, npositive: usize) -> i32 {
    unsafe {
        return secp256k1_pedersen_blind_sum(
            get_context(),
            EBUF1.as_mut_ptr(),
            BLIND_OUTPUT.as_mut_ptr(),
            blinds_size,
            BLINDS.as_mut_ptr(),
            n,
            npositive,
        );
    }
}

//secp256k1_prepare_mlsag
/*
    uint8_t *m, uint8_t *sk, size_t nOuts, size_t nBlinded,  vpInCommitsLen: size_t, vpBlindsLen: size_t, size_t nCols, size_t nRows,
    const uint8_t **pcm_in, const uint8_t **pcm_out, const uint8_t **blinds
*/
// m (buffer, return), sk (buffer, return), pcm_in(pointer to a pointer const), pcm_out(pointer to a pointer const), blinds (pointer to a pointer const) *mut *mut
#[no_mangle]
#[export_name = "prepareMlsag"]
pub extern "C" fn prepare_mlsag(
    n_outs: usize,
    n_blinded: usize,
    vp_in_commits_len: usize,
    vp_blinds_len: usize,
    n_cols: usize,
    n_rows: usize,
) -> i32 {
    unsafe {
        return secp256k1_prepare_mlsag(
            EBUF1.as_mut_ptr(),
            EBUF2.as_mut_ptr(),
            EBUF3.as_mut_ptr(),
            M_INPUT.as_mut_ptr(),
            SK_INPUT.as_mut_ptr(),
            n_outs,
            n_blinded,
            vp_in_commits_len,
            vp_blinds_len,
            n_cols,
            n_rows,
            PCM_IN.as_mut_ptr(),
            PCM_OUT.as_mut_ptr(),
            BLINDS.as_mut_ptr(),
        );
    }
}

//secp256k1_generate_mlsag
/*
    const rustsecp256k1_v0_4_1_context *ctx,
    uint8_t *ki, uint8_t *pc, uint8_t *ps,
    const uint8_t *nonce, const uint8_t *preimage, size_t nCols,
    size_t nRows, size_t index, sk_size, const uint8_t **sk, const uint8_t *pk)
*/
// ki (return), pc (return), ps (return)
#[no_mangle]
#[export_name = "generateMlsag"]
pub extern "C" fn generate_mlsag(
    n_cols: usize,
    n_rows: usize,
    index: usize,
    sk_size: usize,
) -> i32 {
    unsafe {
        return secp256k1_generate_mlsag(
            get_context(),
            EBUF1.as_mut_ptr(),
            KI_BIG_OUTPUT.as_mut_ptr(),
            PC_OUTPUT.as_mut_ptr(),
            PS_OUTPUT.as_mut_ptr(),
            NONCE_OUTPUT.as_mut_ptr(),
            PREIMAGE_INPUT.as_mut_ptr(),
            n_cols,
            n_rows,
            index,
            sk_size,
            SKS_INPUT.as_mut_ptr(),
            PKS_INPUT.as_mut_ptr(),
        );
    }
}

//secp256k1_verify_mlsag
/*
    const rustsecp256k1_v0_4_1_context *ctx,
    const uint8_t *preimage, size_t nCols, size_t nRows,
    const uint8_t *pk, const uint8_t *ki, const uint8_t *pc, const uint8_t *ps
*/
// everything const, only return matter
#[no_mangle]
#[export_name = "verifyMlsag"]
pub extern "C" fn verify_mlsag(n_cols: usize, n_rows: usize) -> i32 {
    unsafe {
        return secp256k1_verify_mlsag(
            get_context(),
            PREIMAGE_INPUT.as_mut_ptr(),
            n_cols,
            n_rows,
            PKS_INPUT.as_mut_ptr(),
            KI_BIG_OUTPUT.as_mut_ptr(),
            PC_OUTPUT.as_mut_ptr(),
            PS_OUTPUT.as_mut_ptr(),
        );
    }
}

#[no_mangle]
#[export_name = "pkTweakAddRaw"]
pub extern "C" fn point_add_raw() -> i32 {
    unsafe {
        //let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        if secp256k1_ec_pubkey_tweak_add_raw(
            get_context(),
            PUBLIC_KEY_INPUT.as_mut_ptr(),
            TWEAK_INPUT.as_ptr(),
        ) == 1
        {
            //pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}

#[no_mangle]
#[export_name = "seckeyVerify"]
pub extern "C" fn seckey_verify() -> i32 {
    unsafe {
        //let mut pk = jstry!(pubkey_parse(PUBLIC_KEY_INPUT.as_ptr(), inputlen), 0);
        if secp256k1_ec_seckey_verify(get_context(), PUBLIC_KEY_INPUT.as_mut_ptr()) == 1 {
            //pubkey_serialize(&pk, PUBLIC_KEY_INPUT.as_mut_ptr(), outputlen);
            1
        } else {
            0
        }
    }
}
