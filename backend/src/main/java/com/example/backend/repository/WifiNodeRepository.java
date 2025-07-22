package com.example.backend.repository;

import com.example.backend.model.WifiNode;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WifiNodeRepository extends JpaRepository<WifiNode, String> {
}
