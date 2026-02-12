package com.pjtf.payments;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    @PostMapping("/process")
    public ResponseEntity<String> process(@RequestBody String orderId) {
        System.out.println("💳 Processing order: " + orderId);
        return ResponseEntity.ok("Payment received: " + orderId);
    }
}