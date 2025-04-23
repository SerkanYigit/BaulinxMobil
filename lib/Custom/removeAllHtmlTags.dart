String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  RegExp exp2 = RegExp(r"(&.+;)", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '').replaceAll(exp2, '');
}