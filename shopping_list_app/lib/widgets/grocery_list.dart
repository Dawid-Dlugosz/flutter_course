import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  initState() {
    super.initState();

    _loadItems();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
      'shopping-finanse-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list.json',
    );
    http.Response? response;

    try {
      response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'error';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _error = 'error';
      });
    }

    final Map<String, dynamic> body = json.decode(response!.body);

    if (body == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final loadedItems = <GroceryItem>[];
    for (var item in body.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.category == item.value['category'])
          .value;
      final groceryItem = GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      );

      loadedItems.add(groceryItem);
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void addItem(BuildContext context) async {
    await Navigator.of(context)
        .push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    )
        .then((value) {
      if (value != null) {
        setState(() {
          _groceryItems.add(value);
        });
      }
    });
  }

  Future<void> _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-finanse-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );

    try {
      await http.delete(url);
    } catch (e) {
      _groceryItems.insert(index, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => addItem(context),
            icon: const Icon(Icons.add),
          ),
        ],
        title: const Text('Your groceries'),
      ),
      body: _error != null
          ? Center(
              child: Text(_error!),
            )
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _groceryItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (ctx, index) => Dismissible(
                        key: ValueKey(_groceryItems[index].id),
                        onDismissed: (_) {
                          _removeItem(_groceryItems[index]);
                        },
                        child: ListTile(
                          title: Text(_groceryItems[index].name),
                          leading: Container(
                            width: 24,
                            height: 24,
                            color: _groceryItems[index].category.color,
                          ),
                          trailing: Text(
                            _groceryItems[index].quantity.toString(),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'EMPTY LSIT',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
    );
  }
}
