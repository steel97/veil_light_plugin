export function resize(arr: Array<any>, newSize: number, defaultValue: any) {
    return [...arr, ...Array(Math.max(newSize - arr.length, 0)).fill(defaultValue)];
}

export function resizeNumArr(arr: Array<any>, newSize: number) {
    for (let i = 0; i < newSize; i++) {
        arr[i] = [];
    }
    return arr;
}

export function resizeBuf(buf: Buffer, size: number) {
    if (buf.length > size)
        return buf.slice(0, size);

    const carr = Buffer.alloc(size);
    carr.set(buf, 0);
    return carr;
}

export function createArrayBuf(arraySize: number, fillSize: number) {
    const ab: Array<Buffer> = [];
    for (let i = 0; i < arraySize; i++) {
        ab[i] = Buffer.alloc(fillSize, 0);
    }
    return ab;
}