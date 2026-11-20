package com.gateprogress.chat;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    private final ChatClient chatClient;

    public ChatController(ChatClient.Builder builder) {
        this.chatClient = builder
                .defaultSystem("""
                    You are a supportive GATE computer science study coach.
                    Explain concepts clearly and help the student plan manageable
                    study steps. Use any supplied study-progress summary to make
                    your advice personal. Keep answers focused and encouraging.
                    """)
                .build();
    }

    @PostMapping
    public ChatReply chat(@Valid @RequestBody ChatRequest request) {
        StringBuilder conversation = new StringBuilder();

        if (request.studyContext() != null && !request.studyContext().isBlank()) {
            conversation.append("Student's saved study progress:\n")
                    .append(request.studyContext())
                    .append("\n--- End of progress summary ---\n\n");
        }

        if (request.history() != null) {
            for (ChatTurn turn : request.history()) {
                if (!turn.role().equals("user") && !turn.role().equals("assistant")) {
                    throw new IllegalArgumentException(
                            "Each history role must be user or assistant.");
                }
                conversation.append(turn.role())
                        .append(": ")
                        .append(turn.text())
                        .append("\n");
            }
        }

        conversation.append("user: ").append(request.message());

        String reply = chatClient.prompt()
                .user(conversation.toString())
                .call()
                .content();

        return new ChatReply(reply);
    }

    public record ChatRequest(
            @NotBlank @Size(max = 2000) String message,
            @Size(max = 12) List<@Valid ChatTurn> history,
            @Size(max = 3000) String studyContext) {}

    public record ChatTurn(
            @NotBlank String role,
            @NotBlank @Size(max = 2000) String text) {}

    public record ChatReply(String reply) {}
}
