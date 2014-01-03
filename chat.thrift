namespace java com.chat.api

struct ChatMessage {
  1: string content,
  2: string sender,
  3: string recipient
}

 service ChatAPI {
  string addNewUser(1: string username),
  string sendMessage(1: string message, 2: string username, 3: string token),
  list<ChatMessage> getConversation(1: string username, 2: string token),
  void registerAndroidToken(1: string pushToken, 2: string token),
  void registeriOSToken(1: string pushToken, 2: string token)
}