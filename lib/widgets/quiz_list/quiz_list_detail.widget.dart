import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './quiz_item.widget.dart';
import './quiz_item_ad.widget.dart';
import './quiz_item_none.widget.dart';
import './advertising_modal.widget.dart';
import '../../providers/quiz.provider.dart';
import '../../quiz_data.dart';

class QuizListDetail extends HookWidget {
  final int openingNumber;
  final ValueNotifier<int> screenNo;
  final int numOfPages;

  QuizListDetail(
    this.openingNumber,
    this.screenNo,
    this.numOfPages,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final AudioCache soundEffect = useProvider(soundEffectProvider).state;

    return Container(
      height: height > 610
          ? 420
          : height > 480
              ? 338
              : height * 0.65,
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      child: Stack(
        children: [
          ListView.builder(
            itemBuilder: (ctx, index) {
              int quizNumber = index + 6 * (screenNo.value);
              return quizNumber < openingNumber
                  ? QuizItem(QUIZ_DATA[quizNumber])
                  : openingNumber < QUIZ_DATA.length
                      ? QuizItemAd(QUIZ_DATA[quizNumber])
                      : quizNumber == QUIZ_DATA.length
                          ? QuizItemNone(openingNumber + 1)
                          : Container();
            },
            itemCount:
                screenNo.value + 1 == numOfPages && openingNumber % 6 == 0
                    ? 3
                    : 6,
          ),
          screenNo.value + 1 == numOfPages && openingNumber != QUIZ_DATA.length
              ? Opacity(
                  opacity: 0.8,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: openingNumber % 6 == 0
                          ? height > 620
                              ? 8
                              : 6
                          : height > 620
                              ? 212
                              : 176,
                      left: 5,
                      right: 5,
                    ),
                    child: InkWell(
                      onTap: () => {
                        soundEffect.play('sounds/hint.mp3',
                            isNotification: true),
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.QUESTION,
                          headerAnimationLoop: false,
                          animType: AnimType.BOTTOMSLIDE,
                          body: AdvertisingModal(openingNumber),
                        )..show(),
                      },
                      child: Container(
                        height: height > 620 ? 187 : 159,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            AppLocalizations.of(context)!.getNewQuiz,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: height > 620 ? 22 : 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
