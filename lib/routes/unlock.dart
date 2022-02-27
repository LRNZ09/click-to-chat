import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const _kProductsFallbackData = {
  'coffee': {
    'description': 'Support the app developer 👨‍💻',
    'emoji': '☕️',
    'title': 'Buy me a coffee',
  },
};

final _kProductIds = _kProductsFallbackData.keys.toSet();

class Unlock extends StatefulWidget {
  const Unlock({Key? key}) : super(key: key);

  @override
  _UnlockState createState() => _UnlockState();
}

class _UnlockState extends State<Unlock> {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  late String _queryProductError;

  @override
  void initState() {
    super.initState();

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      // onError: (error) {
      //   sentry.captureException(exception: error);
      // },
    );

    _initInAppPurchasesState();
  }

  Future<void> _initInAppPurchasesState() async {
    final isAvailable = await InAppPurchase.instance.isAvailable();

    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final productDetailResponse =
        await InAppPurchase.instance.queryProductDetails(_kProductIds);

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = productDetailResponse.error?.message ?? '';
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        // _products = productDetailResponse.notFoundIDs
        //     .map(
        //       (value) => ProductDetails(
        //         id: value,
        //         title: 'Unlock the full version',
        //         description: 'Support the app developer 👨‍💻',
        //         price: '€ 1,09',
        //       ),
        //     )
        //     .toList();
        _purchases = [];
        // _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    await InAppPurchase.instance.restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stack = <Widget>[];

    if (_queryProductError != null) {
      stack.add(
        Center(
          child: Text(_queryProductError),
        ),
      );
    } else {
      var children = [_buildProductList()];
      // TODO: restore the following code
      // if (isInDebugMode) children.insert(0, _buildConnectionCheckTile());

      stack.add(
        ListView(
          children: children,
        ),
      );
    }

    if (_purchasePending) {
      stack.add(
        Stack(
          children: const [
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: stack,
      ),
    );
  }

  Widget _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }

    final Widget storeHeader = ListTile(
      leading: Icon(
        _isAvailable ? Icons.check : Icons.close,
        color: _isAvailable ? Colors.green : Colors.red,
      ),
      title: Text(
        'The store is ${_isAvailable ? 'available' : 'unavailable'}',
      ),
    );

    final children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        const Divider(),
        const ListTile(
          title: Text(
            'Not connected',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          subtitle: Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Widget _buildProductList() {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching products...'),
        ),
      );
    }

    if (!_isAvailable) {
      return const Card(
        child: ListTile(
          title: Text('Cannot connect to the store'),
        ),
      );
    }

    final purchases = Map.fromEntries(_purchases.map((purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }

      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    final productList = _products
        .map(
          (productDetails) => ListTile(
            title: Text(productDetails.title),
            subtitle: Text(productDetails.description),
            trailing: purchases[productDetails.id] == null
                ? FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () {
                      final purchaseParam = PurchaseParam(
                        productDetails: productDetails,
                        // sandboxTesting: isInDebugMode,
                      );

                      InAppPurchase.instance.buyConsumable(
                        purchaseParam: purchaseParam,
                      );
                    },
                  )
                : const Icon(Icons.check),
          ),
        )
        .toList();

    return Card(
      child: Column(children: productList),
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailsList.forEach((purchaseDetails) async {
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          setState(() {
            _purchasePending = true;
          });
          return;

        case PurchaseStatus.error:
          setState(() {
            _purchasePending = false;
          });
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.badNews),
              content:
                  const Text('It seems there\'s an error with your purchase'),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
          return;

        case PurchaseStatus.purchased:
          setState(() {
            _purchases.add(purchaseDetails);
            _purchasePending = false;
          });
          return;

        case PurchaseStatus.restored:
          // TODO: Handle this case.
          break;
        case PurchaseStatus.canceled:
          // TODO: Handle this case.
          break;
      }
    });
  }
}
