// import 'package:flutter/material.dart';
// import 'package:yademan_system_shop/connections/http_request.dart';
//
// class BillAddressScreen extends StatefulWidget {
//   const BillAddressScreen({Key? key}) : super(key: key);
//
//   @override
//   _BillAddressScreenState createState() => _BillAddressScreenState();
// }
//
// class _BillAddressScreenState extends State<BillAddressScreen> {
//   HttpRequest httpRequest = HttpRequest();
//   bool progress = true;
//   int id = 0;
//   var token = "";
//
//   TextEditingController field_firstname = TextEditingController();
//   TextEditingController field_lastname = TextEditingController();
//   TextEditingController field_phone = TextEditingController();
//   TextEditingController field_country = TextEditingController();
//   TextEditingController field_state = TextEditingController();
//   TextEditingController field_city = TextEditingController();
//   TextEditingController field_address_1 = TextEditingController();
//   TextEditingController field_address_2 = TextEditingController();
//   TextEditingController field_postcode = TextEditingController();
//
//   bool visible_error_empty = false;
//
//   load_detail() async {
//     progress = true;
//     dynamic jsonGetCustomer = await httpRequest.getBillAddress();
//
//     setState(() {
//       field_firstname.text = jsonGetCustomer["first_name"];
//       field_lastname.text = jsonGetCustomer["last_name"];
//       field_phone.text = jsonGetCustomer["phone"];
//       field_country.text = "ایران";
//       field_state.text = jsonGetCustomer["state"];
//       field_city.text = jsonGetCustomer["city"];
//       field_address_1.text = jsonGetCustomer["address_1"];
//       field_address_2.text = jsonGetCustomer["address_2"];
//       field_postcode.text = jsonGetCustomer["postcode"];
//       progress = false;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     load_detail();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var _width = MediaQuery.of(context).size.width;
//     var _height = MediaQuery.of(context).size.height;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         // backgroundColor: Config().backgroundColorPage,
//         appBar: AppBar(
//           title: const Text("آدرس صورت حساب"),
//           centerTitle: true,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: edite_address_content(_width, _height),
//           ),
//         ),
//       ),
//     );
//   }
//
//   edite_address_content(var _width, var _height) {
//     if (progress) {
//       return const CircularProgressIndicator();
//     } else {
//       return SingleChildScrollView(
//         child: Form(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               edit_address_form(
//                 labelText: "نام",
//                 iconData: Icons.person,
//                 controller: field_firstname,
//               ),
//               edit_address_form(
//                 labelText: "نام خانوادگی",
//                 iconData: Icons.person,
//                 controller: field_lastname,
//               ),
//               edit_address_form(
//                 labelText: "شماره تماس",
//                 iconData: Icons.phone_android_rounded,
//                 textInputType: TextInputType.phone,
//                 controller: field_phone,
//               ),
//               edit_address_form(
//                 labelText: "کشور",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_country,
//                 readOnly: true,
//               ),
//               edit_address_form(
//                 labelText: "استان",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_state,
//               ),
//               edit_address_form(
//                 labelText: "شهر",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_city,
//               ),
//               edit_address_form(
//                 labelText: "خیابان، کوچه و ...",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_address_1,
//               ),
//               edit_address_form(
//                 labelText: "پلاک، واحد و ...",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_address_2,
//               ),
//               edit_address_form(
//                 labelText: "کد پستی",
//                 iconData: Icons.location_on_rounded,
//                 controller: field_postcode,
//               ),
//               // Visibility(
//               //   maintainAnimation: true,
//               //   maintainState: true,
//               //   visible: visible_error_empty,
//               //   child: Container(
//               //     margin: const EdgeInsets.symmetric(vertical: 10),
//               //     child: const Text(
//               //       'لطفا ایمیل را وارد کنید',
//               //       style: TextStyle(
//               //         color: Colors.red,
//               //         fontWeight: FontWeight.bold,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               ElevatedButton.icon(
//                 label: const Text("ویرایش"),
//                 icon: const Icon(Icons.check),
//                 style: ElevatedButton.styleFrom(
//                   elevation: 5,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     progress = true;
//                   });
//                   updateAddress(
//                     first_name: field_firstname.text,
//                     last_name: field_lastname.text,
//                     phone: field_phone.text,
//                     state: field_state.text,
//                     city: field_city.text,
//                     address_1: field_address_1.text,
//                     address_2: field_address_2.text,
//                     postcode: field_postcode.text,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }
//
//   edit_address_form({
//     required String labelText,
//     required IconData iconData,
//     TextInputType textInputType = TextInputType.text,
//     required TextEditingController controller,
//     bool readOnly = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: TextFormField(
//         decoration: InputDecoration(
//           labelText: labelText,
//           prefixIcon: Icon(iconData),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: Colors.red,
//             ),
//           ),
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.07,
//           ),
//         ),
//         keyboardType: textInputType,
//         controller: controller,
//         readOnly: readOnly,
//       ),
//     );
//   }
//
//   updateAddress({
//     required String first_name,
//     required String last_name,
//     required String phone,
//     required String state,
//     required String city,
//     required String address_1,
//     required String address_2,
//     required String postcode,
//   }) async {
//     await httpRequest.updateBillAddress(
//       first_name: first_name,
//       last_name: last_name,
//       phone: phone,
//       state: state,
//       city: city,
//       address_1: address_1,
//       address_2: address_2,
//       postcode: postcode,
//     );
//     setState(() {
//       progress = false;
//     });
//     final snackBar = SnackBar(
//       backgroundColor: Colors.green.shade700,
//       content: const Text(
//         'آدرس صورت حساب شما ذخیره شد',
//         textAlign: TextAlign.center,
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }
