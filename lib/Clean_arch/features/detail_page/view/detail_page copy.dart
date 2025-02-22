/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/custom_circle_avatar.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/horizantal_card.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/task_card.dart';
import 'package:undede/model/Common/Commons.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: primaryColor2,
        // const Color(0xFFF5F7FA),
        primaryColor: Colors.amberAccent,
        // const Color(0xFFCED5E0),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3A4B),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  GetAllCommonsResult _commons = GetAllCommonsResult(hasError: false);
  //List<CommonBoardListItem> publicCommonBoardList =  _commons.result!.commonBoardList!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor2,
        // const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          SizedBox(
            width: Get.width - 50,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                HorizontalCard(
                  title: 'Step 1',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                HorizontalCard(
                  title: 'Step 2',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                HorizontalCard(
                  title: 'Step 3',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
                HorizontalCard(
                  title: 'Step 4',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                HorizontalCard(
                  title: 'Step 5',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                HorizontalCard(
                  title: 'Step 6',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          /*    _buildCircularIcon('assets/images/create.png'),
          _buildCircularIcon('assets/images/create.png'),
          _buildCircularIcon('assets/images/create.png'), */
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*      const Text(
                    'New Case Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ), */
                  //? Yatay Card Widget

                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CustomCircleAvatar(
                            title: "title",
                            backgroundColor: Colors.white,
                            onPressed: () {}),
                        const SizedBox(width: 5),
                        CustomCircleAvatar(
                            title: "title",
                            backgroundColor: Colors.white,
                            onPressed: () {}),
                        const SizedBox(width: 5),
                        CustomCircleAvatar(
                            title: "title",
                            backgroundColor: Colors.white,
                            onPressed: () {}),
                        const SizedBox(width: 10),
                        /*    HorizontalCard(
                          title: 'User 1',
                          backgroundColor: Colors.white,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 5),
                        HorizontalCard(
                          title: 'User 2',
                          backgroundColor: Colors.white,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 5),
                        HorizontalCard(
                          title: 'User 3',
                          backgroundColor: Colors.white,
                          onPressed: () {},
                        ),
                    
                     */
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        TaskCard(
                          title: 'Allocate Case to User!',
                          userImage:
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          backgroundColor: const Color(0xFFFFFFFF),
                          titleColor: const Color(0xFF2C3A4B),
                        ),
                        const SizedBox(height: 5),
                        TaskCard(
                          title: 'Acknowledge Case receipt to customer!',
                          userImage:
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          backgroundColor: const Color(0xFFFFFFFF),
                          titleColor: const Color(0xFF2C3A4B),
                        ),
                        const SizedBox(height: 5),
                        TaskCard(
                          title: 'Allocate Case to User!',
                          userImage:
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          backgroundColor: const Color(0xFFFFFFFF),
                          titleColor: const Color(0xFF2C3A4B),
                        ),
                        TaskCard(
                          title: 'Acknowledge Case receipt to customer!',
                          userImage:
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          backgroundColor: const Color(0xFFFFFFFF),
                          titleColor: const Color(0xFF2C3A4B),
                        ),
                        const SizedBox(height: 5),
                        TaskCard(
                          title: 'Allocate Case to User!',
                          userImage:
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          backgroundColor: const Color(0xFFFFFFFF),
                          titleColor: const Color(0xFF2C3A4B),
                        ),
                        const SizedBox(height: 5),
                        const SizedBox(height: 5),

                        /*  
                        const TimelineStep(
                          stepTitle: 'Identify Issue',
                        ),
                        const TimelineStep(
                          stepTitle: 'Identify Issue Impact',
                        ),
                        const TimelineStep(
                          stepTitle: 'Allocate to Resolution Team',
                          isHighlighted: true,
                        ),
                       */
/* 
                        //? Yatay Card Widget
                        SizedBox(
                          height: 20,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              HorizontalCard(
                                title: 'Step 1',
                                backgroundColor: Colors.white,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 5),
                              HorizontalCard(
                                title: 'Step 2',
                                backgroundColor: Colors.white,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 5),
                              HorizontalCard(
                                title: 'Step 3',
                                backgroundColor: Colors.white,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      */
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
            child:

                /*
            ListView.builder(

                 itemCount: commonBoardListItem.todos.length,
                    
                    
                      itemBuilder: (context, index) {
                        boardTodo = commonBoardListItem.todos[index];
                        Color boardColor = boardTodo!.color != ""
                            ? Color(int.parse(
                                boardTodo!.color!.replaceFirst('#', '0xFF')))
                            : Colors.transparent;

                        return Tooltip(
                          message: boardTodo!.content,
                          child: GestureDetector(
                            onTap: () {
                              draggableSheetController
                                  .updateBoardTodoAndListItem(
                                      commonBoardListItem.todos[index],
                                      commonBoardListItem);
                              draggableSheetController.toggleSheet();
                            },
                            child: Column(
                              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  // Use Expanded or Flexible to prevent overflow
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[500]!),
                                      borderRadius: BorderRadius.circular(10),
                                      color: boardColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          20.0), // Adjust padding as needed
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: boardTodo!.iconPath == ""
                                                ? AssetImage(
                                                    'assets/images/create.png')
                                                : NetworkImage(boardTodo!
                                                    .iconPath!), // Ensure valid URL

                                            fit: BoxFit
                                                .cover, // Ensures the image covers the container
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    boardTodo!.content!,
                                    overflow: TextOverflow
                                        .ellipsis, // Avoid text overflow
                                    maxLines: 1, // Limit the text to one line
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                   
            
            
            
            )
*/

                Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCircularIcon('assets/images/icon/blueprint.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
                const SizedBox(height: 16),
                _buildCircularIcon('assets/images/icon/3d-printer.png'),
              ],
            ),
          ),
        ],
      ),
      /*     floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ), */
    );
  }

  Widget _buildCircularIcon(String icon) {
    return CircleAvatar(
      backgroundColor:
          //const Color(0xFFCED5E0),
          Color.fromARGB(254, 225, 228, 234),
      radius: 28,
      child: IconButton(
        icon:
            //Image.network(icon),
            ImageIcon(AssetImage(icon)),
        //  image: AssetImage('assets/icons/plus.png')),
        //Icon(icon, color: Colors.black),

        onPressed: () {},
      ),
    );
  }
}

/* 
class TimelineStep extends StatelessWidget {
  final String stepTitle;
  final bool isHighlighted;

  const TimelineStep({
    super.key,
    required this.stepTitle,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.black : Colors.grey,
            shape: BoxShape.circle,
          ),
        ), 
        const SizedBox(width: 16),
        Text(
          stepTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
 */
 */
