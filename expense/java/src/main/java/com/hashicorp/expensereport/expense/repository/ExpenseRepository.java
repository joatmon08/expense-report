package com.hashicorp.expensereport.expense.repository;

import com.hashicorp.expensereport.expense.domain.ExpenseItem;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.UUID;

public interface ExpenseRepository extends CrudRepository<ExpenseItem, UUID> {
    List<ExpenseItem> findByTripId(String tripId);
}