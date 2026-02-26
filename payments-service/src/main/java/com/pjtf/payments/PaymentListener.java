package com.pjtf.payments;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;

@Service
public class PaymentListener {

    private final SqsClient sqsClient;

    @Value("${aws.sqs.queue_url}")
    private String queueUrl;

    public PaymentListener(SqsClient sqsClient) {
        this.sqsClient = sqsClient;
    }

    
    @Scheduled(fixedDelay = 5000)
    public void pollMessages() {
        ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl)
                .maxNumberOfMessages(5)
                .waitTimeSeconds(10)
                .build();

        List<Message> messages = sqsClient.receiveMessage(receiveRequest).messages();

        for (Message message : messages) {
            System.out.println("Order received: " + message.body());
            
            sqsClient.deleteMessage(to -> to.queueUrl(queueUrl).receiptHandle(message.receiptHandle()));
        }
    }
}
