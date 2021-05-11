import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../widgets/quiz_detail/quiz_detail.widget.dart';
import '../widgets/quiz_detail/quiz_questioned.widget.dart';
import '../widgets/quiz_detail/quiz_answer.widget.dart';

import '../models/quiz.model.dart';

class QuizDetailTabScreen extends HookWidget {
  static const routeName = '/quiz-detail-tab';

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)?.settings.arguments as Quiz;

    final _screen = useState<int>(0);
    final _pageController = usePageController(initialPage: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900]?.withOpacity(0.9),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '問題',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: '質問済',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: '回答',
          ),
        ],
        onTap: (int selectIndex) {
          _screen.value = selectIndex;
          _pageController.animateToPage(selectIndex,
              duration: Duration(milliseconds: 400), curve: Curves.easeOut);
        },
        currentIndex: _screen.value,
      ),
      // body: _views[tabType.index],
      body: PageView(
        controller: _pageController,
        // ページ切り替え時に実行する処理
        // PageViewのonPageChangedはページインデックスを受け取る
        onPageChanged: (index) {
          _screen.value = index;
        },
        children: [
          QuizDetail(quiz),
          QuizQuestioned(),
          QuizAnswer(),
        ],
      ),
    );
  }
}