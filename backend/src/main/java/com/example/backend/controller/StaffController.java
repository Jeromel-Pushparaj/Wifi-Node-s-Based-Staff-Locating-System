package com.example.backend.controller;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.model.Staff;
import com.example.backend.repository.StaffRepository;

@RestController
@RequestMapping("/api/staff")
public class StaffController {

    @Autowired
    private StaffRepository staffRepository;

    // Staff updates their location
    @PostMapping("/update-location")
    public Staff updateLocation(@RequestParam String staffId, @RequestParam String nodeName) {
        Optional<Staff> optionalStaff = staffRepository.findById(staffId);

        if (optionalStaff.isPresent()) {
            Staff staff = optionalStaff.get();
            staff.setLocation(nodeName);
            staff.setLastUpdated(LocalDateTime.now());
            return staffRepository.save(staff);
        } else {
            Staff newStaff = new Staff();
            newStaff.setStaffId(staffId);
            newStaff.setName("Unknown Staff"); // or get name from request
            newStaff.setLocation(nodeName);
            newStaff.setLastUpdated(LocalDateTime.now());
            return staffRepository.save(newStaff);
        }
    }

    //Students fetch staff presence
    @GetMapping("/all")
    public List<Staff> getAllStaffPresence() {
        return staffRepository.findAll();
    }
}

