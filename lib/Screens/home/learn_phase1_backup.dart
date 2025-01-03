// // ignore_for_file: prefer_const_constructors, avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:speakbright_mobile/Routing/router.dart';
// import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
// import 'package:speakbright_mobile/Widgets/cards/phase1Card.dart';
// import 'package:speakbright_mobile/Widgets/cards/topFavorite.dart';
// import 'package:speakbright_mobile/Widgets/constants.dart';
// import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
// import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
// import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
// import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
// import 'package:speakbright_mobile/providers/card_provider.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:accordion/accordion.dart';
// // import 'package:mdi/mdi.dart'; // To use MdiIcons

// class Learn1 extends ConsumerStatefulWidget {
//   const Learn1({super.key});

//   static const String route = "/learn1";
//   static const String path = "/learn1";
//   static const String name = "Learn1";

//   @override
//   ConsumerState<Learn1> createState() => _Learn1State();
// }

// class _Learn1State extends ConsumerState<Learn1> {
//   final TTSService _ttsService = TTSService();
//   final FirestoreService _firestoreService = FirestoreService();

//   // List<String> categories = [];
//   int currentUserPhase = 1;
//   int selectedCategory = 0;
//   bool _isMenuCollapsed = true;
//   String? _selectedTargetCard;
//   int _trials = 5;

//   // List<IconData> icons = [
//   //   Icons.category,
//   //   MdiIcons.foodAppleOutline,
//   //   MdiIcons.teddyBear,
//   //   MdiIcons.emoticonHappyOutline,
//   //   MdiIcons.schoolOutline,
//   //   MdiIcons.weightLifter,
//   //   MdiIcons.broom,
//   //   MdiIcons.sunglasses,
//   //   MdiIcons.accountGroupOutline,
//   //   MdiIcons.earth,
//   // ];

//   @override
//   // void initState() {
//   //   super.initState();
//   //   _firestoreService.fetchCategories().then((value) {
//   //     setState(() {
//   //       categories.addAll(value);
//   //     });
//   //   });
    
//   // }

//   @override
//   void dispose() {
//     _ttsService.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cardsAsyncValue = ref.watch(cardsListProvider);

//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(color: phase1Color),
//         // shadowColor: kblack,
//         backgroundColor: learn1bg,

//         //DONT DELETE!!! THIS IS IF I USE THE CATEGORY FROM FIREBASE

//         // actions: [
//         //   PopupMenuButton<int>(
//         //     icon: Icon(Icons.category, color: phase1Color),
//         //     onSelected: (index) {
//         //       setState(() {
//         //         selectedCategory = index;
//         //       });
//         //     },
//         //     itemBuilder: (context) => List.generate(categories.length, (index) {
//         //       final category = categories[index];
//         //       int colorIndex = index % boxColors.length;
//         //       Color itemColor = boxColors[colorIndex];

//         //       return PopupMenuItem<int>(
//         //         value: index,
//         //         child: Container(
//         //           padding: const EdgeInsets.all(8.0),
//         //           decoration: BoxDecoration(
//         //             color: selectedCategory == index // Highlight selected item
//         //                 ? itemColor
//         //                 : itemColor.withOpacity(0.8), // Default color
//         //             borderRadius: BorderRadius.circular(10.0),
//         //             boxShadow: selectedCategory == index // Add glow effect
//         //                 ? [
//         //                     BoxShadow(
//         //                       color: itemColor, // Set glow color same as the button color
//         //                       spreadRadius: 3, // Spread of the glow
//         //                       blurRadius: 6,  // Intensity of the glow
//         //                       offset: const Offset(0, 0), // Position of the glow
//         //                     ),
//         //                   ]
//         //                 : [],
//         //           ),
//         //           child: Row(
//         //             children: [
//         //               Text(
//         //                 category,
//         //                 style: TextStyle(
//         //                   color: Colors.white,
//         //                   fontSize: 14,
//         //                   fontWeight: FontWeight.bold,
//         //                 ),
//         //               ),
//         //               const SizedBox(width: 6),
//         //               Icon(
//         //                     icons[index % icons.length],
//         //                     color: Colors.white,
//         //                     size: 18,
//         //                   ),
//         //             ],
//         //           ),
//         //         ),
//         //       );
//         //     }),
//         //   ),
//         // ],



//         //USING STATIC CATEGORY FOR OPTIMIZATION
//         actions: [
//           PopupMenuButton<int>(
//             icon: Icon(Icons.category, color: phase1Color),
//             onSelected: (index) {
//               setState(() {
//                 selectedCategory = index;
//               });
//             },
//             itemBuilder: (context) => List.generate(phase1Categories.length, (index) {
//               final category = phase1Categories[index];
//               int colorIndex = index % boxColors.length;
//               Color itemColor = boxColors[colorIndex];

//               return PopupMenuItem<int>(
//                 value: index,
//                 child: Container(
//                   padding: const EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     color: selectedCategory == index // Highlight selected item
//                         ? itemColor
//                         : itemColor.withOpacity(0.8), // Default color
//                     borderRadius: BorderRadius.circular(10.0),
//                     boxShadow: selectedCategory == index // Add glow effect
//                         ? [
//                             BoxShadow(
//                               color: itemColor, // Set glow color same as the button color
//                               spreadRadius: 3, // Spread of the glow
//                               blurRadius: 6,  // Intensity of the glow
//                               offset: const Offset(0, 0), // Position of the glow
//                             ),
//                           ]
//                         : [],
//                   ),
//                   child: Row(
//                     children: [
//                       Text(
//                         category,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Icon(
//                             phase1Icons[index % phase1Icons.length],
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],



//       ),
//       backgroundColor: learn1bg,
//       floatingActionButton: Align(
//         alignment: Alignment.bottomCenter,
//         child: Padding(
//           padding: EdgeInsets.only(bottom: 0),
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 20,
//               ),
//               PromptButton(
//                   phaseCurrent: currentUserPhase,
//                   onRefresh: () {
//                     setState(() {});
//                   }),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               'assets/bg-1.1.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Overlay if you need it
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.7), // Adjust opacity as needed
//             ),
//           ),

//           Positioned.fill(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: 
                  
//                   // cardsAsyncValue.when(
//                   //   data: (cards) {
//                   //     List<String> availableCards =
//                   //         cards.map((card) => card.title).toList();
//                   //     List<CardModel> filteredCards = cards.cast<CardModel>();
//                   //     if (_selectedTargetCard != null) {
//                   //       filteredCards = cards
//                   //           .where((card) => card.title == _selectedTargetCard)
//                   //           .cast<CardModel>()
//                   //           .toList();
//                   //     }
//                       return Column(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               children: [
//                                 // Stack(
//                                 //   children: [
//                                 //     SizedBox(
//                                 //       width: MediaQuery.of(context).size.width,
//                                 //       height:
//                                 //           MediaQuery.of(context).size.height *
//                                 //               0.20,
//                                 //       // color: scoreYellow,
//                                 //       child: Padding(
//                                 //         padding:
//                                 //             const EdgeInsets.only(top: 10.0),
//                                 //         child: Center(
//                                 //           child: _isMenuCollapsed
//                                 //               ? Stack(
//                                 //                   children: [
//                                 //                     Row(
//                                 //                       mainAxisAlignment:
//                                 //                           MainAxisAlignment
//                                 //                               .center,
//                                 //                       children: [
//                                 //                         Text(
//                                 //                           'Phase',
//                                 //                           style: GoogleFonts
//                                 //                               .rubikSprayPaint(
//                                 //                             color: phase1Color,
//                                 //                             fontSize: 50,
//                                 //                             letterSpacing: 0.5,
//                                 //                             shadows: [
//                                 //                               Shadow(
//                                 //                                 color: Colors
//                                 //                                     .black
//                                 //                                     .withOpacity(
//                                 //                                         0.5),
//                                 //                                 offset: Offset(
//                                 //                                     3, 3),
//                                 //                                 blurRadius: 5,
//                                 //                               ),
//                                 //                             ],
//                                 //                           ),
//                                 //                         ),
//                                 //                         Image.asset(
//                                 //                           'assets/phase/1.png',
//                                 //                           height: 80,
//                                 //                         )
//                                 //                       ],
//                                 //                     ),
//                                 //                     Positioned(
//                                 //                       left: 0,
//                                 //                       child: GestureDetector(
//                                 //                         onTap: () {
//                                 //                           setState(() {
//                                 //                             _isMenuCollapsed =
//                                 //                                 !_isMenuCollapsed;
//                                 //                           });
//                                 //                         },
//                                 //                         child: ClipRRect(
//                                 //                           borderRadius:
//                                 //                               const BorderRadius
//                                 //                                   .only(
//                                 //                             topRight:
//                                 //                                 Radius.circular(
//                                 //                                     20.0),
//                                 //                             bottomRight:
//                                 //                                 Radius.circular(
//                                 //                                     20.0),
//                                 //                           ),
//                                 //                           child: Container(
//                                 //                             width: 30.0,
//                                 //                             height: 80.0,
//                                 //                             color: dullpurple,
//                                 //                             child: Center(
//                                 //                               child:
//                                 //                                   Image.asset(
//                                 //                                 'assets/option_expand.png',
//                                 //                                 width: 30,
//                                 //                               ),
//                                 //                             ),
//                                 //                           ),
//                                 //                         ),
//                                 //                       ),
//                                 //                     )
//                                 //                   ],
//                                 //                 )
//                                 //               : Row(
//                                 //                   mainAxisAlignment:
//                                 //                       MainAxisAlignment.center,
//                                 //                   children: [
//                                 //                     Container(
//                                 //                       width:
//                                 //                           MediaQuery.of(context)
//                                 //                                   .size
//                                 //                                   .width *
//                                 //                               0.9,
//                                 //                       height:
//                                 //                           MediaQuery.of(context)
//                                 //                                   .size
//                                 //                                   .height *
//                                 //                               0.20,
//                                 //                       decoration: BoxDecoration(
//                                 //                         color: Colors.white,
//                                 //                         borderRadius:
//                                 //                             BorderRadius
//                                 //                                 .circular(20.0),
//                                 //                         border: Border.all(
//                                 //                           color: lGray,
//                                 //                           width: 2.0,
//                                 //                         ),
//                                 //                         boxShadow: [
//                                 //                           BoxShadow(
//                                 //                             color: Colors.black
//                                 //                                 .withOpacity(
//                                 //                                     0.2),
//                                 //                             spreadRadius: 2,
//                                 //                             blurRadius: 5,
//                                 //                             offset:
//                                 //                                 const Offset(
//                                 //                                     3, 3),
//                                 //                           ),
//                                 //                         ],
//                                 //                       ),
//                                 //                       child: Padding(
//                                 //                           padding:
//                                 //                               const EdgeInsets
//                                 //                                   .all(5.0),
//                                 //                           child: Column(
//                                 //                             mainAxisAlignment:
//                                 //                                 MainAxisAlignment
//                                 //                                     .start,
//                                 //                             children: [
//                                 //                               Row(
//                                 //                                 children: [
//                                 //                                   Text(
//                                 //                                     '1 ',
//                                 //                                     style: GoogleFonts.roboto(
//                                 //                                         color: boxColors[
//                                 //                                             0],
//                                 //                                         fontWeight:
//                                 //                                             FontWeight
//                                 //                                                 .bold,
//                                 //                                         fontSize:
//                                 //                                             24),
//                                 //                                   ),
//                                 //                                   Text(
//                                 //                                     'Choose a Category',
//                                 //                                     style: GoogleFonts.singleDay(
//                                 //                                         color:
//                                 //                                             lGray,
//                                 //                                         fontSize:
//                                 //                                             20),
//                                 //                                   )
//                                 //                                 ],
//                                 //                               ),
//                                 //                               SizedBox(
//                                 //                                 height: 50,
//                                 //                                 child: ListView
//                                 //                                     .builder(
//                                 //                                   scrollDirection:
//                                 //                                       Axis.horizontal,
//                                 //                                   itemCount:
//                                 //                                       categories
//                                 //                                           .length,
//                                 //                                   itemBuilder:
//                                 //                                       (context,
//                                 //                                           index) {
//                                 //                                     final category =
//                                 //                                         categories[
//                                 //                                             index];
//                                 //                                     int colorIndex =
//                                 //                                         index %
//                                 //                                             boxColors.length;
//                                 //                                     Color
//                                 //                                         itemColor =
//                                 //                                         boxColors[
//                                 //                                             colorIndex];

//                                 //                                     //temporary, to be added in firebase
//                                 //                                     List<IconData>
//                                 //                                         icons =
//                                 //                                         [
//                                 //                                       Icons
//                                 //                                           .category,
//                                 //                                       MdiIcons
//                                 //                                           .foodAppleOutline,
//                                 //                                       MdiIcons
//                                 //                                           .teddyBear,
//                                 //                                       MdiIcons
//                                 //                                           .emoticonHappyOutline,
//                                 //                                       MdiIcons
//                                 //                                           .schoolOutline,
//                                 //                                       MdiIcons
//                                 //                                           .weightLifter,
//                                 //                                       MdiIcons
//                                 //                                           .broom,
//                                 //                                       MdiIcons
//                                 //                                           .sunglasses,
//                                 //                                       MdiIcons
//                                 //                                           .accountGroupOutline,
//                                 //                                       MdiIcons
//                                 //                                           .earth,
//                                 //                                     ];
//                                 //                                     bool
//                                 //                                         isSelected =
//                                 //                                         selectedCategory ==
//                                 //                                             index;

//                                 //                                     return GestureDetector(
//                                 //                                       onTap:
//                                 //                                           () {
//                                 //                                         setState(
//                                 //                                             () {
//                                 //                                           selectedCategory =
//                                 //                                               index;
//                                 //                                         });
//                                 //                                       },
//                                 //                                       child:
//                                 //                                           Container(
//                                 //                                         margin: const EdgeInsets
//                                 //                                             .all(
//                                 //                                             8.0),
//                                 //                                         padding: const EdgeInsets
//                                 //                                             .all(
//                                 //                                             8.0),
//                                 //                                         decoration:
//                                 //                                             BoxDecoration(
//                                 //                                           color:
//                                 //                                               itemColor,
//                                 //                                           borderRadius:
//                                 //                                               BorderRadius.circular(10.0),
//                                 //                                           boxShadow: isSelected
//                                 //                                               ? <BoxShadow>[
//                                 //                                                   BoxShadow(
//                                 //                                                     color: itemColor,
//                                 //                                                     spreadRadius: 1,
//                                 //                                                     blurRadius: 2,
//                                 //                                                     offset: const Offset(0, 1),
//                                 //                                                   ),
//                                 //                                                 ]
//                                 //                                               : [],
//                                 //                                         ),
//                                 //                                         child:
//                                 //                                             Row(
//                                 //                                           mainAxisAlignment:
//                                 //                                               MainAxisAlignment.spaceBetween,
//                                 //                                           children: [
//                                 //                                             Text(
//                                 //                                               category,
//                                 //                                               style: const TextStyle(
//                                 //                                                 color: Colors.white,
//                                 //                                                 fontSize: 12,
//                                 //                                                 fontWeight: FontWeight.w400,
//                                 //                                               ),
//                                 //                                             ),
//                                 //                                             Icon(
//                                 //                                               icons[index % icons.length],
//                                 //                                               color: Colors.white,
//                                 //                                               size: 15,
//                                 //                                             ),
//                                 //                                           ],
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                     );
//                                 //                                   },
//                                 //                                 ),
//                                 //                               ), //end of category list
//                                 //                               Row(
//                                 //                                 mainAxisAlignment:
//                                 //                                     MainAxisAlignment
//                                 //                                         .spaceBetween,
//                                 //                                 children: [
//                                 //                                   Column(
//                                 //                                     children: [
//                                 //                                       Row(
//                                 //                                         children: [
//                                 //                                           Text(
//                                 //                                             '2 ',
//                                 //                                             style: GoogleFonts.roboto(
//                                 //                                                 color: boxColors[1],
//                                 //                                                 fontWeight: FontWeight.bold,
//                                 //                                                 fontSize: 24),
//                                 //                                           ),
//                                 //                                           Text(
//                                 //                                             'Select a Target Card',
//                                 //                                             style:
//                                 //                                                 GoogleFonts.singleDay(color: lGray, fontSize: 20),
//                                 //                                           )
//                                 //                                         ],
//                                 //                                       ),
//                                 //                                       DropdownButton<
//                                 //                                           String>(
//                                 //                                         value:
//                                 //                                             _selectedTargetCard,
//                                 //                                         hint: const Text(
//                                 //                                             "Select a card"),
//                                 //                                         onChanged:
//                                 //                                             (String?
//                                 //                                                 newValue) {
//                                 //                                           setState(
//                                 //                                               () {
//                                 //                                             _selectedTargetCard =
//                                 //                                                 newValue;
//                                 //                                           });
//                                 //                                         },
//                                 //                                         items: availableCards
//                                 //                                             .map<DropdownMenuItem<String>>(
//                                 //                                           (String
//                                 //                                               value) {
//                                 //                                             return DropdownMenuItem<String>(
//                                 //                                               value: value,
//                                 //                                               child: Text(value),
//                                 //                                             );
//                                 //                                           },
//                                 //                                         ).toList(),
//                                 //                                       ),
//                                 //                                     ],
//                                 //                                   ),
//                                 //                                   Column(
//                                 //                                     children: [
//                                 //                                       Row(
//                                 //                                         children: [
//                                 //                                           Text(
//                                 //                                             '3 ',
//                                 //                                             style: GoogleFonts.roboto(
//                                 //                                                 color: boxColors[4],
//                                 //                                                 fontWeight: FontWeight.bold,
//                                 //                                                 fontSize: 24),
//                                 //                                           ),
//                                 //                                           Text(
//                                 //                                             'Number of Trials',
//                                 //                                             style:
//                                 //                                                 GoogleFonts.singleDay(color: lGray, fontSize: 20),
//                                 //                                           )
//                                 //                                         ],
//                                 //                                       ),
//                                 //                                       DropdownButton<
//                                 //                                           int>(
//                                 //                                         value:
//                                 //                                             _trials,
//                                 //                                         onChanged:
//                                 //                                             (int?
//                                 //                                                 newValue) {
//                                 //                                           setState(
//                                 //                                               () {
//                                 //                                             _trials =
//                                 //                                                 newValue!;
//                                 //                                           });
//                                 //                                         },
//                                 //                                         items: List.generate(
//                                 //                                             16,
//                                 //                                             (index) =>
//                                 //                                                 index +
//                                 //                                                 5).map<
//                                 //                                             DropdownMenuItem<int>>(
//                                 //                                           (int
//                                 //                                               value) {
//                                 //                                             return DropdownMenuItem<int>(
//                                 //                                               value: value,
//                                 //                                               child: Text(value.toString()),
//                                 //                                             );
//                                 //                                           },
//                                 //                                         ).toList(),
//                                 //                                       ),
//                                 //                                     ],
//                                 //                                   ),
//                                 //                                   Padding(
//                                 //                                     padding: const EdgeInsets
//                                 //                                         .only(
//                                 //                                         right:
//                                 //                                             18.0),
//                                 //                                     child:
//                                 //                                         GestureDetector(
//                                 //                                       onTap:
//                                 //                                           () {
//                                 //                                         print(
//                                 //                                             'Container clicked');
//                                 //                                       },
//                                 //                                       child:
//                                 //                                           Container(
//                                 //                                         decoration:
//                                 //                                             BoxDecoration(
//                                 //                                           color:
//                                 //                                               addGreen,
//                                 //                                           borderRadius:
//                                 //                                               BorderRadius.circular(40.0),
//                                 //                                         ),
//                                 //                                         width:
//                                 //                                             100,
//                                 //                                         height:
//                                 //                                             50,
//                                 //                                         child:
//                                 //                                             Center(
//                                 //                                           child:
//                                 //                                               Text(
//                                 //                                             'Set',
//                                 //                                             style:
//                                 //                                                 TextStyle(
//                                 //                                               fontSize: 18,
//                                 //                                               fontWeight: FontWeight.bold,
//                                 //                                               color: kwhite,
//                                 //                                             ),
//                                 //                                           ),
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                     ),
//                                 //                                   )
//                                 //                                 ],
//                                 //                               )
//                                 //                             ],
//                                 //                           )),
//                                 //                     ),
//                                 //                     GestureDetector(
//                                 //                       onTap: () {
//                                 //                         setState(() {
//                                 //                           _isMenuCollapsed =
//                                 //                               !_isMenuCollapsed;
//                                 //                         });
//                                 //                       },
//                                 //                       child: ClipRRect(
//                                 //                         borderRadius:
//                                 //                             const BorderRadius
//                                 //                                 .only(
//                                 //                           topRight:
//                                 //                               Radius.circular(
//                                 //                                   20.0),
//                                 //                           bottomRight:
//                                 //                               Radius.circular(
//                                 //                                   20.0),
//                                 //                         ),
//                                 //                         child: Container(
//                                 //                           width: 30.0,
//                                 //                           height: 80.0,
//                                 //                           color: dullpurple,
//                                 //                           child: Center(
//                                 //                             child: Image.asset(
//                                 //                               'assets/option_collapse.png',
//                                 //                               width: 30,
//                                 //                             ),
//                                 //                           ),
//                                 //                         ),
//                                 //                       ),
//                                 //                     ),
//                                 //                   ],
//                                 //                 ),
//                                 //         ),
//                                 //       ),
//                                 //     )
//                                 //   ],
//                                 // ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(30.0),
//                                   child: Container(child: Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Text(
//                                                             'Phase',
//                                                             style: GoogleFonts
//                                                                 .rubikSprayPaint(
//                                                               color: phase1Color,
//                                                               fontSize: 50,
//                                                               letterSpacing: 0.5,
//                                                               shadows: [
//                                                                 Shadow(
//                                                                   color: Colors
//                                                                       .black
//                                                                       .withOpacity(
//                                                                           0.5),
//                                                                   offset: Offset(
//                                                                       3, 3),
//                                                                   blurRadius: 5,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           Image.asset(
//                                                             'assets/phase/1.png',
//                                                             height: 80,
//                                                           )
//                                                         ],
//                                                       ),),
//                                 ),

//                                 const SizedBox(height: 16),
//                                 //card part
//                                 FutureBuilder<List<CardModel>?>(
//                                   future: TopFavoriteCard
//                                       .fetchTopFavoriteAndDistractorCards(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState ==
//                                         ConnectionState.waiting) {
//                                       return Center(child: WaitingDialog());
//                                     }
                                
//                                     if (snapshot.hasError) {
//                                       return Center(
//                                           child:
//                                               Text('Error: ${snapshot.error}'));
//                                     }
                                
//                                     final List<CardModel>? cards =
//                                         snapshot.data;
                                
//                                     if (cards == null || cards.isEmpty) {
//                                       return Center(
//                                           child:
//                                               Text('No favorite card found.'));
//                                     }
                                
//                                     final CardModel topFavoriteCard = cards[0];
//                                     final CardModel? distractorCard =
//                                         cards.length > 1 ? cards[1] : null;
                                
//                                     // Wrap showDistractor in another FutureBuilder
//                                     return FutureBuilder<bool>(
//                                       future: _firestoreService
//                                           .showDistractor(topFavoriteCard.id),
//                                       builder: (context, distractorSnapshot) {
//                                         if (distractorSnapshot
//                                                 .connectionState ==
//                                             ConnectionState.waiting) {
//                                           return Center(child: WaitingDialog());
//                                         }
                                
//                                         if (distractorSnapshot.hasError) {
//                                           return Center(
//                                               child: Text(
//                                                   'Error: ${distractorSnapshot.error}'));
//                                         }
                                
//                                         bool _showDistractor =
//                                             distractorSnapshot.data ?? false;
                                
//                                         return Padding(
//                                           padding: const EdgeInsets.all(16.0),
//                                           child: _showDistractor == false
//                                               ? Column(
//                                                   children: [
//                                                     Phase1Card(
//                                                       fontSize: 20,
//                                                       card: topFavoriteCard,
//                                                       onTap: () {
//                                                         final cardTitle =
//                                                             topFavoriteCard
//                                                                 .title;
//                                                         final category =
//                                                             topFavoriteCard
//                                                                 .category;
//                                                         final cardId =
//                                                             topFavoriteCard.id;
//                                                         print(
//                                                             'Top Favorite - title: $cardTitle, cat: $category');
                                
//                                                         _ttsService
//                                                             .speak(cardTitle);
//                                                         _firestoreService
//                                                             .storeTappedCards(
//                                                                 cardTitle,
//                                                                 category,
//                                                                 cardId);
//                                                       },
//                                                     ),
//                                                   ],
//                                                 )
//                                               : Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Phase1Card(
//                                                       fontSize: 20,
//                                                       card: topFavoriteCard,
//                                                       onTap: () {
//                                                         final cardTitle =
//                                                             topFavoriteCard
//                                                                 .title;
//                                                         final category =
//                                                             topFavoriteCard
//                                                                 .category;
//                                                         final cardId =
//                                                             topFavoriteCard.id;
//                                                         print(
//                                                             'Top Favorite - title: $cardTitle, cat: $category');
                                
//                                                         _ttsService
//                                                             .speak(cardTitle);
//                                                         _firestoreService
//                                                             .storeTappedCards(
//                                                                 cardTitle,
//                                                                 category,
//                                                                 cardId);
//                                                       },
//                                                     ),
//                                                     SizedBox(width: 25),
//                                                     if (_showDistractor && distractorCard !=
//                                                           null)
                                            
//                                                         Phase1Card(
//                                                           widthFactor: 0.35,
//                                                           heightFactor: 0.35,
//                                                           card: distractorCard,
//                                                           onTap: () {
//                                                             final cardTitle =
//                                                                 distractorCard
//                                                                     .title;
//                                                             final category =
//                                                                 distractorCard
//                                                                     .category;
//                                                             print(
//                                                                 'Distractor - title: $cardTitle, cat: $category');
//                                                             _ttsService.speak(
//                                                                 cardTitle);
//                                                           },
//                                                         ),
//                                                   ],
//                                                 ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                 //     },
//                 //     loading: () {
//                 //       print('Loading cards...');
//                 //       return const Center(child: WaitingDialog());
//                 //     },
//                 //     error: (error, stack) {
//                 //       print('Error fetching cards: $error');
//                 //       return Center(child: Text('Error: $error'));
//                 //     },
//                 //   ),
//                 // ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
