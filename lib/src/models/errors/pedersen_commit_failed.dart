class PedersenCommitFailed implements Exception {
  String cause;
  PedersenCommitFailed(this.cause);
}
