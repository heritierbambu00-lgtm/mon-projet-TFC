import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import '../providers/social_providers.dart';
import '../../domain/entities/chat_faculte_entity.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentFaculte = "Général";
  
  bool _showEmoji = false;
  bool _isRecording = false;
  bool _isSearching = false;
  bool _isMuted = false;
  
  final Set<String> _selectedMessageIds = {};
  
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- LOGIQUE MÉTIER ---

  void _sendMessage(String idEtu, String nomComplet, {MessageType type = MessageType.text, String? mediaUrl, String? text}) async {
    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty && mediaUrl == null) return;

    if (text == null) _messageController.clear();
    
    try {
      await ref.read(socialRepositoryProvider).sendMessage(
        idEtu: idEtu,
        nomComplet: nomComplet,
        message: msgText,
        faculte: _currentFaculte,
        type: type,
        mediaUrl: mediaUrl,
      );
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'envoi : $e")));
      }
    }
  }

  Future<void> _sendImage(String idEtu, String nomComplet) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Envoi de l'image en cours...")));
      
      try {
        final String fileName = "chat_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final String? downloadUrl = await ref.read(socialRepositoryProvider).uploadMedia(
          File(image.path), 
          'chat/$_currentFaculte/$fileName'
        );

        if (downloadUrl != null) {
          _sendMessage(idEtu, nomComplet, type: MessageType.image, mediaUrl: downloadUrl, text: "📷 Photo");
        } else {
          _sendMessage(idEtu, nomComplet, type: MessageType.image, mediaUrl: image.path, text: "📷 Photo (Locale)");
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur upload : $e")));
      }
    }
  }

  Future<void> _toggleRecording(String idEtu, String nomComplet) async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        _sendMessage(idEtu, nomComplet, type: MessageType.audio, mediaUrl: path, text: "🎤 Message vocal");
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  // --- ACTIONS DE SUPPRESSION ---

  Future<void> _deleteSelectedMessages(String myId, List<ChatFaculteEntity> allMessages) async {
    if (_selectedMessageIds.isEmpty) return;

    // Vérifier si tous les messages sélectionnés m'appartiennent
    final selectedMsgs = allMessages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    final bool allMine = selectedMsgs.every((m) => m.idEtu == myId);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("Supprimer les messages ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (allMine)
              ListTile(
                title: const Text("Supprimer pour tous", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(socialRepositoryProvider).deleteForEveryone(_selectedMessageIds.toList());
                  setState(() => _selectedMessageIds.clear());
                },
              ),
            ListTile(
              title: const Text("Supprimer pour moi", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(socialRepositoryProvider).deleteForMe(_selectedMessageIds.toList(), myId);
                setState(() => _selectedMessageIds.clear());
              },
            ),
            ListTile(
              title: const Text("Annuler"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAllChat(String myId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vider la discussion ?"),
        content: const Text("Voulez-vous vraiment effacer les messages de votre écran ? Les autres membres les verront toujours."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ANNULER")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("VIDER", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(socialRepositoryProvider).clearChatForMe(_currentFaculte, myId);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  // --- ACTIONS DU MENU ---

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Infos du Forum $_currentFaculte", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primaryBlue, child: Icon(Icons.groups_rounded, color: Colors.white, size: 40)),
            const SizedBox(height: 20),
            const Text("Espace d'échange officiel des étudiants et professeurs de l'ISTM-MAHAGI.", textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("Membres : Promotion active", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("FERMER"))],
      ),
    );
  }

  void _showMediaGallery(List<ChatFaculteEntity> messages) {
    final images = messages.where((m) => m.type == MessageType.image && m.mediaUrl != null).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 20),
            const Text("MÉDIAS PARTAGÉS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final url = images[index].mediaUrl!;
                  return GestureDetector(
                    onTap: () => _openFullscreenImage(url),
                    child: url.startsWith('http') 
                        ? Image.network(url, fit: BoxFit.cover) 
                        : Image.file(File(url), fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenImage(String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(
          child: url.startsWith('http') ? Image.network(url) : Image.file(File(url)),
        ),
      ),
    )));
  }

  void _showQuickActions(ChatFaculteEntity msg, String myId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.reply), title: const Text('Répondre'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.star_outline), title: const Text('Ajouter aux favoris'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.copy), title: const Text('Copier'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.forward), title: const Text('Transférer'), onTap: () => Navigator.pop(context)),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red), 
            title: const Text('Supprimer', style: TextStyle(color: Colors.red)), 
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedMessageIds.add(msg.id));
              // On simule une liste de messages ici pour le dialogue
              _deleteSelectedMessages(myId, []); 
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Color _getSenderColor(String name) {
    final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.teal];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final messagesAsync = ref.watch(messagesStreamProvider(_currentFaculte));

    return userAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
        
        final String myId = user.id;
        final String myName = user is EtudiantEntity ? "${user.prenomEtu} ${user.nomEtu}" : "Utilisateur";

        return WillPopScope(
          onWillPop: () async {
            if (_selectedMessageIds.isNotEmpty) { setState(() => _selectedMessageIds.clear()); return false; }
            if (_showEmoji) { setState(() => _showEmoji = false); return false; }
            if (_isSearching) { setState(() => _isSearching = false); return false; }
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFE5DDD5),
            appBar: _buildWhatsAppAppBar(context, messagesAsync.value ?? [], myId),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'),
                        opacity: 0.06,
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                    child: messagesAsync.when(
                      data: (messages) {
                        // FILTER: Exclude messages deleted for me
                        final visibleMessages = messages.where((m) => !m.deletedBy.contains(myId)).toList();

                        final filteredMessages = _isSearching && _searchController.text.isNotEmpty
                            ? visibleMessages.where((m) => m.message.toLowerCase().contains(_searchController.text.toLowerCase())).toList()
                            : visibleMessages;

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          reverse: true,
                          itemCount: filteredMessages.length,
                          itemBuilder: (context, index) {
                            final msg = filteredMessages[index];
                            final bool isMe = msg.idEtu == myId;
                            final bool isSelected = _selectedMessageIds.contains(msg.id);
                            
                            return _buildWhatsAppBubbleWithAvatar(msg, isMe, isSelected, myId);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Erreur : $e")),
                    ),
                  ),
                ),
                if (!_isSearching && _selectedMessageIds.isEmpty) _buildWhatsAppInput(myId, myName),
                if (_showEmoji) _buildEmojiPicker(),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Erreur profil : $e"))),
    );
  }

  PreferredSizeWidget _buildWhatsAppAppBar(BuildContext context, List<ChatFaculteEntity> messages, String myId) {
    if (_selectedMessageIds.isNotEmpty) {
      return AppBar(
        backgroundColor: const Color(0xFF075E54),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedMessageIds.clear())),
        title: Text("${_selectedMessageIds.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.reply, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.star, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () => _deleteSelectedMessages(myId, messages)),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
        ],
      );
    }

    if (_isSearching) {
      return AppBar(
        backgroundColor: const Color(0xFF075E54),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _isSearching = false)),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Rechercher...", hintStyle: TextStyle(color: Colors.white60), border: InputBorder.none),
          onChanged: (v) => setState(() {}),
        ),
      );
    }

    return AppBar(
      backgroundColor: const Color(0xFF075E54),
      elevation: 5,
      leadingWidth: 75,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            const SizedBox(width: 4),
            const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.groups_rounded, color: Colors.white, size: 20)),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Forum $_currentFaculte", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_isMuted ? "🔇 Silence activé" : "En ligne...", style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call, color: Colors.white), onPressed: () {}),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (val) {
            if (val == 'info') _showGroupInfo();
            if (val == 'media') _showMediaGallery(messages);
            if (val == 'search') setState(() => _isSearching = true);
            if (val == 'mute') setState(() => _isMuted = !_isMuted);
            if (val == 'clear') _clearAllChat(myId);
            if (val == 'exit') Navigator.pop(context);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'info', child: Text('Infos du groupe')),
            const PopupMenuItem(value: 'media', child: Text('Médias, liens et docs')),
            const PopupMenuItem(value: 'search', child: Text('Recherche')),
            PopupMenuItem(value: 'mute', child: Text(_isMuted ? 'Rétablir le son' : 'Silence')),
            const PopupMenuItem(value: 'clear', child: Text('Effacer la discussion (Vider)')),
            const PopupMenuItem(value: 'exit', child: Text('Quitter le groupe')),
          ],
        ),
      ],
    );
  }

  Widget _buildWhatsAppBubbleWithAvatar(ChatFaculteEntity msg, bool isMe, bool isSelected, String myId) {
    final time = DateFormat('HH:mm').format(msg.dateEnvoi);
    final String initial = msg.nomUtilisateur.isNotEmpty ? msg.nomUtilisateur[0].toUpperCase() : "?";
    final Color nameColor = _getSenderColor(msg.nomUtilisateur);
    final bool isDeleted = msg.type == MessageType.deleted;

    return InkWell(
      onLongPress: () {
        if (!isDeleted) setState(() => _selectedMessageIds.add(msg.id));
      },
      onDoubleTap: () {
        if (!isDeleted) _showQuickActions(msg, myId);
      },
      onTap: () {
        if (_selectedMessageIds.isNotEmpty) {
          setState(() {
            if (isSelected) {
              _selectedMessageIds.remove(msg.id);
            } else {
              _selectedMessageIds.add(msg.id);
            }
          });
        } else if (msg.type == MessageType.image && !isDeleted) {
          _openFullscreenImage(msg.mediaUrl!);
        }
      },
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 16,
                backgroundColor: nameColor.withOpacity(0.8),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDeleted 
                      ? Colors.grey.shade100.withOpacity(0.5)
                      : (isMe ? const Color(0xFFDCF8C6) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 10 : 0),
                    topRight: Radius.circular(isMe ? 0 : 10),
                    bottomLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 1, offset: const Offset(0, 1))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMe && !isDeleted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(msg.nomUtilisateur, style: TextStyle(fontWeight: FontWeight.bold, color: nameColor, fontSize: 12)),
                      ),
                    if (isDeleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.block, size: 14, color: Colors.black38),
                          SizedBox(width: 5),
                          Text("Ce message a été supprimé", style: TextStyle(color: Colors.black38, fontSize: 13, fontStyle: FontStyle.italic)),
                        ],
                      )
                    else ...[
                      if (msg.type == MessageType.image && msg.mediaUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: msg.mediaUrl!.startsWith('http') 
                            ? Image.network(msg.mediaUrl!, width: 250, height: 200, fit: BoxFit.cover) 
                            : Image.file(File(msg.mediaUrl!), width: 250, height: 200, fit: BoxFit.cover),
                        ),
                      if (msg.type == MessageType.audio)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.grey, size: 35), onPressed: () => _audioPlayer.play(DeviceFileSource(msg.mediaUrl!))),
                            const Text("Message vocal", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      if (msg.type == MessageType.text)
                        Text(msg.message, style: const TextStyle(color: Colors.black87, fontSize: 15)),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 40),
                        Text(time, style: const TextStyle(color: Colors.black45, fontSize: 10)),
                        if (isMe && !isDeleted) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all, color: Colors.blue, size: 16),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppInput(String idEtu, String myName) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined, color: Colors.grey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onTap: () => setState(() => _showEmoji = false),
                      decoration: const InputDecoration(hintText: 'Message', border: InputBorder.none),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: () => _sendImage(idEtu, myName)),
                  IconButton(icon: const Icon(Icons.camera_alt, color: Colors.grey), onPressed: () => _sendImage(idEtu, myName)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onLongPress: () => _toggleRecording(idEtu, myName),
            onTap: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(idEtu, myName);
              } else {
                _toggleRecording(idEtu, myName);
              }
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF075E54),
              child: Icon(_messageController.text.trim().isEmpty ? (_isRecording ? Icons.stop : Icons.mic) : Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) => _messageController.text += emoji.emoji,
        config: Config(
          height: 256,
          emojiViewConfig: EmojiViewConfig(
            columns: 7, emojiSizeMax: 32, recentsLimit: 28,
            noRecents: const Text('Aucun emoji récent', style: TextStyle(fontSize: 20, color: Colors.black26), textAlign: TextAlign.center),
            buttonMode: ButtonMode.MATERIAL,
          ),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.RECENT,
            indicatorColor: Color(0xFF075E54),
            iconColorSelected: Color(0xFF075E54),
          ),
        ),
      ),
    );
  }
}
