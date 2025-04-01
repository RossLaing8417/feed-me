import 'package:flutter/material.dart';

class AppHomeView extends StatefulWidget {
  const AppHomeView({super.key});

  @override
  State<AppHomeView> createState() => _AppHomeViewState();
}

class _AppHomeViewState extends State<AppHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppRecipeCard(
                title: "Some Food",
                cookTime: "Long",
                rating: "123",
              ),
              AppRecipeCard(
                title: "More Food",
                cookTime: "Short",
                rating: "avg",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppRecipeCard extends StatelessWidget {
  final String title;
  final String rating;
  final String cookTime;
  final String thumbnailUrl =
      "https://images.unsplash.com/photo-1498837167922-ddd27525d352?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHJhbmRvbSUyMGZvb2QlMjBzdG9yZXxlbnwwfHwwfHx8MA%3D%3D";

  const AppRecipeCard({
    super.key,
    required this.title,
    required this.cookTime,
    required this.rating,
    // required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      width: MediaQuery.of(context).size.width,
      height: 180.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            offset: Offset(0.0, 10.0),
            blurRadius: 10.0,
            spreadRadius: -6.0,
          ),
        ],
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(85),
            BlendMode.multiply,
          ),
          image: NetworkImage(thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 19),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    // color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 18),
                      SizedBox(width: 7.0),
                      Text(rating),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    // color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.yellow, size: 18.0),
                      SizedBox(width: 7.0),
                      Text(cookTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
