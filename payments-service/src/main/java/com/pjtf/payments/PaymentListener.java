package com.pjtf.payments;

import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;

@Service
public class PaymentListener {

    private final SqsClient sqsClient;
    private final String queueUrl = "http://localhost:4566/000000000000/q-orders-dev";

    public PaymentListener(SqsClient sqsClient) {
        this.sqsClient = sqsClient;
    }

    
    @Scheduled(fixedDelay = 5000)
    public void pollMessages() {
        ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl)
                .maxNumberOfMessages(5)
                .waitTimeSeconds(10) // Long Polling
                .build();

        List<Message> messages = sqsClient.receiveMessage(receiveRequest).messages();

        for (Message message : messages) {
            System.out.println("Order received: " + message.body());
            
            sqsClient.deleteMessage(to -> to.queueUrl(queueUrl).receiptHandle(message.receiptHandle()));
        }
    }
}
