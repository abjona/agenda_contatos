import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions{orderaz, orderza}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contact = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
           itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
             const PopupMenuItem<OrderOptions>(
               child: Text("Ordernar de A-Z"),
               value: OrderOptions.orderaz,
             ),
             const PopupMenuItem<OrderOptions>(
               child: Text("Ordernar de Z-A"),
               value: OrderOptions.orderza,
             ),
           ] ,
           onSelected: _orderList,
          )
        ],
      ),
      
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contact.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                      image: contact[index].img != null
                          ? FileImage(File(contact[index].img))
                          : AssetImage('images/person.png')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contact[index].email ?? "",
                        style: TextStyle(fontSize: 18.0)),
                    Text(contact[index].phone ?? "",
                        style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Ligar",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          launch("tel:${contact[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(context, contact: contact[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Excluir",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          setState(() {
                            helper.deleteContact(contact[index].id);
                            contact.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Future _showContactPage(context, {Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        contact = list;
      });
    });
  }

  
  void _orderList(OrderOptions result){
    switch (result) {
      case OrderOptions.orderaz:
        contact.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
      contact.sort((b,a){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
     
    }
    setState(() {
      
    });
  }
}
