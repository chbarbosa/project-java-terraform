package com.pjtf;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlResponse;

@Service
public class OrderService {

    private final SqsClient sqsClient;

    @Value("${aws.sqs.queue_url")
    private String queueUrl;

    public OrderService(SqsClient sqsClient) {
        this.sqsClient = sqsClient;
    }

    public void sendToQueue(String orderId) {
        GetQueueUrlResponse getQueueUrlResponse = 
        sqsClient.getQueueUrl(GetQueueUrlRequest.builder().queueName("q-orders-dev").build());
        String qu = getQueueUrlResponse.queueUrl();
        sqsClient.sendMessage(to -> to.queueUrl(qu).messageBody(orderId));
        System.out.println("Order sent: " + orderId);
    }
}
