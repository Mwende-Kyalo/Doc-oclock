package com.example.telemed.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.data.local.ChatMessage
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.ChatViewModel

@Composable
fun ChatScreen(chatViewModel: ChatViewModel = viewModel(), receiverId: Int) {
    if (LocalInspectionMode.current) {
        ChatContent(messages = emptyList(), messageText = "", onMessageChange = {}, onSendMessage = {})
        return
    }
    val messages by chatViewModel.messages.collectAsState()
    ChatContent(
        messages = messages,
        messageText = chatViewModel.messageText,
        onMessageChange = { chatViewModel.messageText = it },
        onSendMessage = { chatViewModel.sendMessage(receiverId) }
    )
}

@Composable
fun ChatContent(
    messages: List<ChatMessage>,
    messageText: String,
    onMessageChange: (String) -> Unit,
    onSendMessage: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        LazyColumn(
            modifier = Modifier.weight(1f),
            reverseLayout = true
        ) {
            items(messages.reversed()) { message ->
                // This is a placeholder for the actual user ID
                val isSentByCurrentUser = message.senderId == 1
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = if (isSentByCurrentUser) Arrangement.End else Arrangement.Start
                ) {
                    Card(
                        modifier = Modifier.padding(vertical = 4.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = if (isSentByCurrentUser) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary
                        )
                    ) {
                        Text(
                            text = message.message,
                            modifier = Modifier.padding(8.dp),
                            color = if (isSentByCurrentUser) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSecondary
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = messageText,
                onValueChange = onMessageChange,
                modifier = Modifier.weight(1f)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Button(onClick = onSendMessage) {
                Text("Send")
            }
        }
    }
}


@Preview(showBackground = true)
@Composable
fun ChatScreenPreview() {
    TelemedTheme {
        val fakeMessages = listOf(
            ChatMessage(id = 1, appointmentId = 1, senderId = 1, receiverId = 2, message = "Hello!", timestamp = 0),
            ChatMessage(id = 2, appointmentId = 1, senderId = 2, receiverId = 1, message = "Hi there!", timestamp = 0),
            ChatMessage(id = 3, appointmentId = 1, senderId = 1, receiverId = 2, message = "How are you?", timestamp = 0)
        )
        ChatContent(
            messages = fakeMessages,
            messageText = "",
            onMessageChange = {},
            onSendMessage = {}
        )
    }
}