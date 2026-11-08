import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  bool _scanHandled = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kDefaultPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: ListTile(
                      leading: result != null
                          ? const Icon(
                              Icons.check_circle,
                              color: CupertinoColors.activeGreen,
                            )
                          : const CupertinoActivityIndicator(),
                      title: result != null
                          ? Text('Processing...'.tr)
                          : Text('Looking for QR Code...'.tr),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 180.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: kPrimaryColor,
          borderRadius: 9,
          borderLength: 30,
          borderWidth: 9,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Future<bool> wasTheCodeUsed({
    required String campaignUid,
    required String taskUid,
    required String shopUid,
    required String userUid,
  }) async {
    bool alreadyUsed = true;
    await FirebaseFirestore.instance
        .collection("shops")
        .doc(shopUid)
        .collection("shop_purchases")
        .where("campaignUid", isEqualTo: campaignUid)
        .where("taskUid", isEqualTo: taskUid)
        .where("shopUid", isEqualTo: shopUid)
        .where("userUid", isEqualTo: userUid)
        .count()
        .get()
        .then((value) {
      alreadyUsed = (value.count ?? 0) > 0;
    });
    return alreadyUsed;
  }

  Future<bool> doesShopOwnerHasPermission({required String shopUid}) async {
    bool isShopOwner = false;
    await FirebaseFirestore.instance
        .collection("shops")
        .doc(shopUid)
        .get()
        .then((value) {
      if (value.exists) {
        isShopOwner = value.data()!['managerUid'] ==
            FirebaseAuth.instance.currentUser?.uid;
      }
    });
    return isShopOwner;
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      // Handle only the first scan: the stream keeps emitting while the code
      // stays in view, and each event would record a purchase.
      if (_scanHandled) return;
      _scanHandled = true;
      setState(() {
        result = scanData;
      });
      controller.pauseCamera();
      SmartDialog.showLoading(msg: 'Processing...'.tr);
      String userUid = '';
      if (scanData.code != null) {
        List<String> codes = scanData.code!.split("_");
        if (codes.length == 4) {
          try {
            String shopUid = codes[2];
            userUid = codes[3];
            bool isShopOwner =
                await doesShopOwnerHasPermission(shopUid: shopUid);
            bool alreadyUsed = await wasTheCodeUsed(
                campaignUid: codes[0],
                taskUid: codes[1],
                shopUid: shopUid,
                userUid: userUid);
            if (alreadyUsed || !isShopOwner) {
              SmartDialog.dismiss();
              SmartDialog.showNotify(
                  msg: "This qr code already has been used before.".tr,
                  notifyType: NotifyType.alert);
              Get.back();
              return;
            }
            await FirebaseFirestore.instance
                .collection("shops")
                .doc(shopUid)
                .collection("shop_purchases")
                .add({
              "campaignUid": codes[0],
              "taskUid": codes[1],
              "shopUid": shopUid,
              "userUid": userUid,
              'timestamp': DateTime.now(),
            });
            //todo one idea is to save to user purchase collection and listen to the doc created change
            HttpsCallable callable = FirebaseFunctions.instance
                .httpsCallable('TransferERC20TokenFromUidV2');
            await callable.call(<String, dynamic>{
              'transferredAmount': 3,
              'uid': userUid,
            });
          } catch (e) {
            debugPrint("$e");
            SmartDialog.dismiss();
            SmartDialog.showNotify(
                msg: "Error, could not finish the process".tr,
                notifyType: NotifyType.alert);
            Get.back();
            return;
          }
        } else {
          debugPrint("There is wrong format".tr);
          SmartDialog.dismiss();
          await SmartDialog.showNotify(
            msg: 'Invalid QR code'.tr,
            notifyType: NotifyType.failure,
          );
          Get.back();
          return;
        }
      }
      SmartDialog.dismiss();
      await SmartDialog.showNotify(
          msg: 'Successfully completed!'.tr, notifyType: NotifyType.success);
      Get.back();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera Permission Denied'.tr),
        ),
      );
    }
  }

  // QRViewController disposes itself when the QRView is unmounted.
}
