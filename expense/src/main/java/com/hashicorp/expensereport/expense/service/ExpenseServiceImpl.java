package com.hashicorp.expensereport.expense.service;

import com.hashicorp.expensereport.expense.domain.ExpenseItem;
import com.hashicorp.expensereport.expense.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ExpenseServiceImpl implements ExpenseService {
    @Autowired
    private ExpenseRepository expenseRepo;
    public ExpenseServiceImpl() {}

    @Override
    public List<ExpenseItem> listExpenses() {
        List<ExpenseItem> expenseItems = new ArrayList<>();
        expenseRepo.findAll().forEach(expenseItems::add);
        return expenseItems;
    }

    @Override
    public Optional<ExpenseItem> getExpense(UUID id) {
        return expenseRepo.findById(id);
    }

    @Override
    public List<ExpenseItem> listExpensesByTrip(String tripId) {
        return new ArrayList<>(expenseRepo.findByTripId(tripId));
    }

    @Override
    public ExpenseItem addExpenseItem(ExpenseItem item) {
        return expenseRepo.save(item);
    }

    @Override
    public void deleteExpenseItem(UUID id) {
        expenseRepo.deleteById(id);
    }
}
