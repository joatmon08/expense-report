package com.hashicorp.expensereport.expense.controller;

import com.hashicorp.expensereport.expense.domain.ExpenseItem;
import com.hashicorp.expensereport.expense.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping(path="/api/expense")
public class ExpenseController{
    @Autowired
    private ExpenseService expenseService;

    @GetMapping
    public List<ExpenseItem> getExpenses() {
        return expenseService.listExpenses();
    }

    @GetMapping(path="{id}")
    public ResponseEntity<ExpenseItem> getExpenseById(@PathVariable("id") UUID id) {
        return ResponseEntity.of(expenseService.getExpense(id));
    }

    @GetMapping(path="/trip/{tripId}")
    public List<ExpenseItem> getExpensesByTripId(@PathVariable("tripId") String tripId) {
        return expenseService.listExpensesByTrip(tripId);
    }

    @PostMapping
    public ExpenseItem createExpenses(@RequestBody ExpenseItem expense) {
        return expenseService.addExpenseItem(expense);
    }

    @DeleteMapping(path="{id}")
    public void deleteExpenses(@PathVariable("id") UUID id) {
        expenseService.deleteExpenseItem(id);
    }
}