package com.pjtf.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String customerName;
    private BigDecimal totalValue;
    private String status; // Ex: PENDING, PAID, CANCELLED
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.status = "PENDING";
    }

    // Getters e Setters (Dica: Use a extensão 'Lombok' se preferir não escrever tudo)
}