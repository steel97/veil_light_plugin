import 'dart:typed_data';

class CTxOutBase {
  final int nVersion;

  CTxOutBase({this.nVersion = 0});

  Uint8List serialize() {
    /*switch (this.nVersion)
        {
            case OUTPUT_STANDARD:
                s << *((CTxOutStandard*) this);
                break;
            case OUTPUT_CT:
                s << *((CTxOutCT*) this);
                break;
            case OUTPUT_RINGCT:
                s << *((CTxOutRingCT*) this);
                break;
            case OUTPUT_DATA:
                s << *((CTxOutData*) this);
                break;
            default:
                throw std::runtime_error("serialize error: tx output type does not exist");
        }*/
    return Uint8List(0);
  }
}
