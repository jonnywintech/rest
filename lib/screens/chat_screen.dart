import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';
import 'ai_settings_screen.dart';

const _suggestions = [
  'Osećam se iscrpljeno i ne znam odakle da krenem',
  'Kako da postavim granice na poslu?',
  'Pomozi mi da se smirim',
  'Ne mogu da zaspim od misli',
  'Objasni mi današnji dan izazova',
];

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = text ?? _controller.text;
    if (message.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).send(message);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obrisati razgovor?'),
        content: const Text('Sve poruke sa Mirom biće trajno obrisane sa ovog uređaja.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Otkaži')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Obriši',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) ref.read(chatProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final hasKey = ref.watch(settingsProvider.select((s) => s.hasKey));
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            MiraAvatar(size: 38),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mira',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('AI saputnica',
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ],
            ),
          ],
        ),
        actions: [
          if (chat.messages.isNotEmpty)
            IconButton(
              tooltip: 'Obriši razgovor',
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: !hasKey
          ? Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  emoji: '🔑',
                  title: 'Mira čeka ključ',
                  text: gt(
                      'Da bi razgovara{o|la} sa Mirom, dodaj besplatni Gemini API ključ. Napravićeš ga za minut na aistudio.google.com.',
                      profile.gender),
                  action: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AiSettingsScreen())),
                    icon: const Icon(Icons.key_rounded),
                    label: const Text('Dodaj API ključ'),
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: chat.messages.isEmpty
                      ? _Intro(name: profile.name, onSuggestion: _send)
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: chat.messages.length + (chat.sending ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (chat.sending && i == 0) return const _TypingBubble();
                            final index = chat.messages.length - 1 - (i - (chat.sending ? 1 : 0));
                            return _Bubble(message: chat.messages[index]);
                          },
                        ),
                ),
                if (chat.error != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(chat.error!,
                              style: const TextStyle(color: AppColors.danger)),
                        ),
                        TextButton(
                          onPressed: ref.read(chatProvider.notifier).retry,
                          child: const Text('Ponovo'),
                        ),
                      ],
                    ),
                  ),
                _InputBar(
                  controller: _controller,
                  enabled: !chat.sending,
                  onSend: _send,
                ),
              ],
            ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.name, required this.onSuggestion});

  final String name;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        const Center(child: MiraAvatar(size: 84)),
        const SizedBox(height: 18),
        Text(
          name.isEmpty ? 'Ćao, ja sam Mira 👋' : 'Ćao $name, ja sam Mira 👋',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tu sam da te saslušam bez osuđivanja, pomognem ti da sagledaš situaciju i predložim mali korak koji možeš da napraviš danas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 24),
        for (final s in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              radius: 18,
              onTap: () => onSuggestion(s),
              child: Row(
                children: [
                  Expanded(
                      child: Text(s,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  const Icon(Icons.north_east_rounded,
                      size: 18, color: AppColors.blue),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Mira je AI i može da pogreši. Nije zamena za stručnu pomoć.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth:
                (MediaQuery.sizeOf(context).width * 0.8).clamp(0, 416).toDouble()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          boxShadow: isUser ? null : AppColors.cardShadow,
        ),
        child: SelectableText.rich(
          _formatted(message.text,
              TextStyle(
                color: isUser ? Colors.white : AppColors.ink,
                fontSize: 15.5,
                height: 1.45,
              )),
        ),
      ),
    );
  }

  /// Minimalna podrška za **podebljan** tekst i liste sa „*“ / „-“.
  TextSpan _formatted(String text, TextStyle style) {
    final normalized = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^\s*[\*\-]\s+'), '• '))
        .join('\n');
    final spans = <TextSpan>[];
    final parts = normalized.split('**');
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w800) : null,
      ));
    }
    return TextSpan(style: style, children: spans);
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(
                      alpha: 0.3 +
                          0.7 *
                              (1 -
                                  ((_controller.value * 3 - i) % 3)
                                      .clamp(0.0, 1.0)),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enabled ? onSend() : null,
                decoration: InputDecoration(
                  hintText: 'Napiši poruku…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide:
                        const BorderSide(color: AppColors.green, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.green,
                minimumSize: const Size(52, 52),
              ),
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
