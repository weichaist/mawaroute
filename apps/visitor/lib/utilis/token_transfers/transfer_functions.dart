import 'package:cloud_functions/cloud_functions.dart';

Future transferERC20TokenFromUid({
  required int transferredAmount,
  required String uid,
}) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    "TransferERC20TokenFromUidV2",
  );
  await callable.call(<String, dynamic>{
    "transferredAmount": transferredAmount,
    "uid": uid,
  });
}
