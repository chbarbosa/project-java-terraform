package com.pjtf;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ListObjectsResponse;
import software.amazon.awssdk.services.s3.model.S3Object;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/files")
public class FileController {

    private final S3Client s3Client;
    
    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    public FileController(S3Client s3Client) { this.s3Client = s3Client; }

    @GetMapping("path")
    public String getMethodName(@RequestParam String param) {
        return new String();
    }

    @GetMapping("/health-check")
    public Map<String, String> status() {
        return Map.of(
            "status", "UP",
            "bucket", bucketName
        );
    }
    
    public List<String> listFiles() {
        ListObjectsResponse response = s3Client.listObjects(r -> r.bucket(bucketName));
        return response.contents().stream().map(S3Object::key).toList();
    }
}