package com.pjtf;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class OrderService {

    private final RestTemplate restTemplate;

    @Value("${INTERNAL_PAYMENTS_URL}") 
    private String paymentsUrl;

    public OrderService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void createOrder(String orderId) {
        System.out.println("Order " + orderId + " created. Calling payments...");
        
        String url = paymentsUrl + "/payments/process";
        String response = restTemplate.postForObject(url, orderId, String.class);
        
        System.out.println("Ansqer from Payments service: " + response);
    }
}
