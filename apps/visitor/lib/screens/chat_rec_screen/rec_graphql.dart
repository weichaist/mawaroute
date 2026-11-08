String generateWhereCondition(List<String> recUids) {
  if (recUids.isEmpty) {
    return '';
  }
  List<String> operands = recUids.map((uid) {
    return ''',{path: ["id"],operator: NotEqual,valueText:"$uid"}''';
  }).toList();
  return operands.join('');
}

String recWeaviateQuery({
  required String avatarUid,
  required String concept,
  required List<String> shownRecUids,
}) {
  return """
        {
          Get {
            AvatarRec(
              limit: 3
              nearText: {concepts: ["$concept"]}
              where:{operator: And, operands: [{path: ["avatarUid"], operator: Equal, valueText: "$avatarUid"}${generateWhereCondition(shownRecUids)}]}
            ) {
              title
              description
              price
              link
              geo {
                latitude
                longitude
              }
              _additional {
                id
              }
            }
          }
        }
        """;
}
