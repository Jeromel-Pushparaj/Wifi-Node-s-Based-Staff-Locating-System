package com.example.backend.controller;

import com.example.backend.model.WifiNode;
import com.example.backend.repository.WifiNodeRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/nodes")
public class WifiNodeController {

    private final WifiNodeRepository wifiNodeRepository;

    public WifiNodeController(WifiNodeRepository wifiNodeRepository) {
        this.wifiNodeRepository = wifiNodeRepository;
    }

    // GET all nodes
    @GetMapping
    public List<WifiNode> getAllNodes() {
        return wifiNodeRepository.findAll();
    }

    // POST to add a new node
    @PostMapping
    public WifiNode addNode(@RequestBody WifiNode wifiNode) {
        return wifiNodeRepository.save(wifiNode);
    }
}
