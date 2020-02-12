package com.hashicorp.expensereport.expense.service;

import com.hashicorp.expensereport.expense.domain.ExpenseItem;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExpenseService {
    List<ExpenseItem> listExpenses();
    List<ExpenseItem> listExpensesByTrip(String tripId);
    Optional<ExpenseItem> getExpense(UUID id);
    ExpenseItem addExpenseItem(ExpenseItem item);
//    public void updateExpenseItem(ExpenseItem item);
    void deleteExpenseItem(UUID id);
}
