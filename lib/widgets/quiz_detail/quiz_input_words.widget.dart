import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import 'package:matcher/matcher.dart';

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

    // if (!existFlg) {
    //   context.read(askingQuestionsProvider).state = [];
    // } else {
    //   List<Question> createdQuestions = [];

    //   remainingQuestions.forEach((question) {
    //     if (question.asking
    //         .split(subject)[1]
    //         .split(relatedWord)[1]
    //         .isNotEmpty) {
    //       createdQuestions.add(question);
    //     }
    //   });

    //   context.read(askingQuestionsProvider).state = createdQuestions;
    // }

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
      final randomNumber = new Random().nextInt(5);
      if (randomNumber == 0) {
        context.read(beforeWordProvider).state =
            AppLocalizations.of(context)!.seekHint;
      } else {
        context.read(beforeWordProvider).state =
            AppLocalizations.of(context)!.noQuestions;
      }
    } else {
      context.read(selectedQuestionProvider).state = dummyQuestion;
      context.read(beforeWordProvider).state =
          AppLocalizations.of(context)!.selectQuestion;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectFocusNode = useFocusNode();
    final relatedWordFocusNode = useFocusNode();

    final List<Question> remainingQuestions =
        useProvider(remainingQuestionsProvider).state;

    final int hint = useProvider(hintProvider).state;

    final String? selectedSubject = useProvider(selectedSubjectProvider).state;
    final String? selectedRelatedWord =
        useProvider(selectedRelatedWordProvider).state;

    subjectFocusNode.addListener(() {
      if (!subjectFocusNode.hasFocus) {
        _submitData(
          context,
          quiz,
          remainingQuestions,
          selectedQuestion,
          askingQuestions,
        );
      }
    });

    relatedWordFocusNode.addListener(() {
      if (!relatedWordFocusNode.hasFocus) {
        _submitData(
          context,
          quiz,
          remainingQuestions,
          selectedQuestion,
          askingQuestions,
        );
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * .35 < 210 ? 6 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // 主語の入力
          hint < 1
              ? _wordForQuestion(
                  context,
                  AppLocalizations.of(context)!.subject,
                  subjectController,
                  subjectFocusNode,
                )
              : _wordSelectForQuestion(
                  context,
                  selectedSubject,
                  selectedSubjectProvider,
                  AppLocalizations.of(context)!.subject,
                  hint,
                  quiz.subjects,
                  subjectController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                ),
          Text(
            AppLocalizations.of(context)!.afterSubject,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontFamily: 'NotoSerifJP',
            ),
          ),
          // 関連語の入力
          hint < 1
              ? _wordForQuestion(
                  context,
                  AppLocalizations.of(context)!.relatedWord,
                  relatedWordController,
                  relatedWordFocusNode,
                )
              : _wordSelectForQuestion(
                  context,
                  selectedRelatedWord,
                  selectedRelatedWordProvider,
                  AppLocalizations.of(context)!.relatedWord,
                  hint,
                  quiz.relatedWords.take(quiz.hintDisplayWordId).toList(),
                  relatedWordController,
                  remainingQuestions,
                  selectedQuestion,
                  askingQuestions,
                ),
          Text(
            '...？',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontFamily: 'NotoSerifJP',
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordForQuestion(BuildContext context, String text,
      TextEditingController controller, FocusNode _focusNode) {
    final height = MediaQuery.of(context).size.height * .35;

    return Container(
      width: MediaQuery.of(context).size.width * .30,
      height: height < 210 ? 50 : null,
      child: TextField(
        textAlignVertical: height < 210 ? TextAlignVertical.bottom : null,
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
        focusNode: _focusNode,
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
    final height = MediaQuery.of(context).size.height * .35;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 10,
      ),
      width: MediaQuery.of(context).size.width * .305,
      height: height < 210 ? 50 : 63,
      decoration: BoxDecoration(
        color: hint < 2 ? Colors.white : Colors.grey[400],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      alignment: Alignment.center,
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
        items: hint < 2
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
