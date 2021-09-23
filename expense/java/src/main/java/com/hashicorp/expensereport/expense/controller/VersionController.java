package com.hashicorp.expensereport.expense.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path="/api")
public class VersionController {
    @Autowired
    private BuildProperties buildProperties;

    @GetMapping
    public String getVersion() {
        return buildProperties.getVersion();
    }
}
