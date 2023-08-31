String bytesToHexString(List<int>? src) {
  String stringBuilder = "";

  if (src == null || src.isEmpty) {
    return "";
  }

  for (int i = 0; i < src.length; i++) {
    int v = src[i] & 0xFF;
    String hv = v.toRadixString(16).toUpperCase();

    if (hv.length < 2) {
      stringBuilder += "0";
    }

    stringBuilder += hv;

    if (i < src.length - 1) {
      stringBuilder += " ";
    }
  }

  return stringBuilder;
}

List<int> convertHexStringToList(String hexString) {
  List<int> hexList = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String hexByte = hexString.substring(i, i + 2);
    int intValue = int.parse(hexByte, radix: 16);
    hexList.add(intValue);
  }
  return hexList;
}
