class CFeeRate {
  final int nSatoshisPerK;

  CFeeRate({this.nSatoshisPerK = 0});

  int getFee(int nBytes_) {
    //assert(nBytes_ <= uint64_t(std:: numeric_limits<int64_t>:: max()));
    int nSize = nBytes_; //int64_t(nBytes_);

    int nFee = (nSatoshisPerK * nSize / 1000) as int;

    if (nFee == 0 && nSize != 0) {
      if (nSatoshisPerK > 0) {
        nFee = 1;
      }
      if (nSatoshisPerK < 0) {
        nFee = -1;
      }
    }

    return nFee;
  }
}
