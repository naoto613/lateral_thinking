import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/quiz.provider.dart';
import '../../models/quiz.model.dart';

class QuizInputWords extends HookWidget {
  final Quiz quiz;
  final Question selectedQuestion;
  final List<Question> askingQuestions;
  final TextEditingController subjectController;
  final TextEditingController relatedWordController;

  QuizInputWords(
    this.quiz,
    this.selectedQuestion,
    this.askingQuestions,
    this.subjectController,
    this.relatedWordController,
  );

  void _submitData(
    BuildContext context,
    Quiz quiz,
    List<Question> remainingQuestions,
    Question selectedQuestion,
    List<Question> askingQuestions,
  ) {
    final enteredSubject = subjectController.text;
    final enteredRelatedWord = relatedWordController.text;

    context.read(beforeWordProvider).state = '';

    if (enteredSubject.isEmpty || enteredRelatedWord.isEmpty) {
      context.read(displayReplyFlgProvider).state = false;
      context.read(selectedQuestionProvider).state = dummyQuestion;
      context.read(askingQuestionsProvider).state = [];

      return;
    }

    _checkQuestions(
      context,
      enteredSubject,
      enteredRelatedWord,
      remainingQuestions,
      quiz.subjects,
      quiz.relatedWords,
      askingQuestions,
    );
  }

  void _checkQuestions(
    BuildContext context,
    String subject,
    String relatedWord,
    List<Question> remainingQuestions,
    List<String> allSubjects,
    List<String> allRelatedWords,
    List<Question> askingQuestions,
  ) {
    bool existFlg = false;

    // 主語リストに存在するか判定
    for (String targetSubject in allSubjects) {
      existFlg = targetSubject == subject ? true : false;
      if (existFlg) {
        break;
      }
    }
    // 主語リストに存在した場合、関連語リストに存在するか判定
    if (existFlg) {
      for (String targetRelatedWords in allRelatedWords) {
        existFlg = targetRelatedWords == relatedWord ? true : false;
        if (existFlg) {
          break;
        }
      }
    }

    context.read(askingQuestionsProvider).state = existFlg
        ? remainingQuestions
            .where((question) =>
                question.asking.startsWith(subject) &&
                (!question.asking.startsWith(relatedWord) &&
                    question.asking.contains(relatedWord)))
            .toList()
        : [];

    context.read(displayReplyFlgProvider).state = false;

    if (context.read(askingQuestionsProvider).state.isEmpty) {
      context.read(beforeWordProvider).state = 'それらの言葉は関係ないようです。';
    } else {
      context.read(selectedQuestionProvider).state = dummyQuestion;
      context.read(beforeWordProvider).state = '↓質問を選択';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Question> remainingQuestions =
        useProvider(remainingQuestionsProvider).state;

    final int hint = useProvider(hintProvider).state;

    final String? selectedSubject = useProvider(selectedSubjectProvider).state;
    final String? selectedRelatedWord =
        useProvider(selectedRelatedWordProvider).state;

    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // 主語の入力
          hint < 1
              ? _wordForQuestion(
                  context,
                  '主語',
                  subjectController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                )
              : _wordSelectForQuestion(
                  context,
                  selectedSubject,
                  selectedSubjectProvider,
                  '主語',
                  hint,
                  quiz.subjects,
                  subjectController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                ),
          Text(
            'は',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          // 関連語の入力
          hint < 2
              ? _wordForQuestion(
                  context,
                  '関連語',
                  relatedWordController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                )
              : _wordSelectForQuestion(
                  context,
                  selectedRelatedWord,
                  selectedRelatedWordProvider,
                  '関連語',
                  hint,
                  quiz.relatedWords.take(quiz.hintDisplayWordId).toList(),
                  relatedWordController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                ),
          Text(
            '...？',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }

  Widget _wordForQuestion(
    BuildContext context,
    String text,
    TextEditingController controller,
    List<Question> remainingQuestions,
    Question selectedQuestion,
    List<Question> askingQuestions,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * .30,
      child: TextField(
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: text,
          enabledBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 3.0,
            ),
          ),
        ),
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(10),
        ],
        controller: controller,
        onSubmitted: (_) => _submitData(
          context,
          quiz,
          remainingQuestions,
          selectedQuestion,
          askingQuestions,
        ),
      ),
    );
  }

  Widget _wordSelectForQuestion(
    BuildContext context,
    String? selectedWord,
    StateProvider<String> selectedWordProvider,
    String displayHint,
    int hint,
    List<String> wordList,
    TextEditingController controller,
    List<Question> remainingQuestions,
    Question selectedQuestion,
    List<Question> askingQuestions,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 10,
      ),
      width: MediaQuery.of(context).size.width * .305,
      height: MediaQuery.of(context).size.height * .083,
      decoration: BoxDecoration(
        color: hint < 3 ? Colors.white : Colors.grey[400],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: DropdownButton(
        isExpanded: true,
        hint: Text(
          displayHint,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        underline: Container(
          color: Colors.white,
        ),
        value: selectedWord != '' ? selectedWord : null,
        items: hint < 3
            ? wordList.map((String word) {
                return DropdownMenuItem(
                  value: word,
                  child: Text(word),
                );
              }).toList()
            : null,
        onChanged: (targetSubject) {
          controller.text = context.read(selectedWordProvider).state =
              targetSubject as String;
          _submitData(
            context,
            quiz,
            remainingQuestions,
            selectedQuestion,
            askingQuestions,
          );
        },
      ),
    );
  }
}