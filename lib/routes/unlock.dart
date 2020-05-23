import 'dart:async';

import 'package:click_to_chat/app_localizations.dart';
import 'package:click_to_chat/debug.dart';
import 'package:click_to_chat/sentry.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mdi/mdi.dart';

const _kProductsFallbackData = {
  'coffee': {
    'description': 'Support the app developer 👨‍💻',
    'emoji': '☕️',
    'title': 'Buy me a coffee',
  },
};

final _kProductIds = _kProductsFallbackData.keys.toSet();

class Unlock extends StatefulWidget {
  @override
  _UnlockState createState() => _UnlockState();
}

class _UnlockState extends State<Unlock> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
    super.initState();

    _subscription = _connection.purchaseUpdatedStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        sentry.captureException(exception: error);
      },
    );

    _initInAppPurchasesState();
  }

  Future<void> _initInAppPurchasesState() async {
    final isAvailable = await _connection.isAvailable();

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
        await _connection.queryProductDetails(_kProductIds);

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = productDetailResponse.error?.message;
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

    final purchaseResponse = await _connection.queryPastPurchases();

    if (purchaseResponse.error != null) {
      // TODO handle query past purchase error...
      return;
    }

    final verifiedPurchases = <PurchaseDetails>[];
    for (final purchase in purchaseResponse.pastPurchases) {
      final isValid = _verifyPurchase(purchase);
      if (isValid) {
        verifiedPurchases.add(purchase);
      }
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      // _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
    });
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
      if (isInDebugMode) children.insert(0, _buildConnectionCheckTile());

      stack.add(
        ListView(
          children: children,
        ),
      );
    }

    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
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
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }

    final Widget storeHeader = ListTile(
      leading: Icon(
        _isAvailable ? Mdi.check : Mdi.close,
        color: _isAvailable ? Colors.green : Colors.red,
      ),
      title: Text(
        'The store is ' + (_isAvailable ? 'available' : 'unavailable'),
      ),
    );

    final children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text(
            'Not connected',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Widget _buildProductList() {
    if (_loading) {
      return Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching products...'),
        ),
      );
    }

    if (!_isAvailable) {
      return Card(
        child: ListTile(
          title: Text('Cannot connect to the store'),
        ),
      );
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verity the purchase data.
    final purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _connection.completePurchase(purchase);
      }

      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    final productList = _products
        .map(
          (ProductDetails productDetails) => ListTile(
            title: Text(
              '${productDetails.title ?? _kProductsFallbackData[productDetails.id]['title']} ${_kProductsFallbackData[productDetails.id]['emoji']}',
            ),
            subtitle: Text(
              productDetails.description ??
                  _kProductsFallbackData[productDetails.id]['description'],
            ),
            trailing: purchases[productDetails.id] == null
                ? FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () {
                      final purchaseParam = PurchaseParam(
                        productDetails: productDetails,
                        sandboxTesting: isInDebugMode,
                      );

                      _connection.buyConsumable(
                        purchaseParam: purchaseParam,
                      );
                    },
                  )
                : Icon(Mdi.check),
          ),
        )
        .toList();

    return Card(
      child: Column(children: productList),
    );
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return purchaseDetails.verificationData.serverVerificationData != null;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.pendingCompletePurchase) {
        await _connection.completePurchase(purchaseDetails);
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
            builder: (BuildContext context) => AlertDialog(
              title: Text(AppLocalizations.of(context).badNews),
              content: Text('It seems there\'s an error with your purchase'),
              actions: [
                FlatButton(
                  child: Text(AppLocalizations.of(context).close.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
          return;

        case PurchaseStatus.purchased:
          final isValid = _verifyPurchase(purchaseDetails);
          if (isValid) {
            setState(() {
              _purchases.add(purchaseDetails);
              _purchasePending = false;
            });
          }
      }
    });
  }
}
