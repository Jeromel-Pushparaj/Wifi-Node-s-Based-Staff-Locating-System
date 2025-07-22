package com.example.backend.service;

import com.example.backend.model.Staff;
import com.example.backend.repository.StaffRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StaffService {
    private final StaffRepository repository;

    public StaffService(StaffRepository repository) {
        this.repository = repository;
    }

    public Staff updateLocation(String staffId, String nodeName) {
        Staff staff = repository.findById(staffId).orElseThrow(
            () -> new RuntimeException("Staff not found: " + staffId));
        staff.setLocation(nodeName);
        staff.setLastUpdated(LocalDateTime.now());
        return repository.save(staff);
    }

    public List<Staff> getAllStaff() {
        return repository.findAll();
    }
}
