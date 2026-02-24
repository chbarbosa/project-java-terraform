package com.pjtf;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.services.sqs.SqsClient;

@Service
public class OrderService {

    private final SqsClient sqsClient;

    @Value("${aws.sqs.queue_url}")
    private String queueUrl;

    public OrderService(SqsClient sqsClient) {
        this.sqsClient = sqsClient;
    }

    public void sendToQueue(String orderId) {
        sqsClient.sendMessage(to -> to.queueUrl(queueUrl).messageBody(orderId));
        System.out.println("Order sent: " + orderId);
    }
}
