package com.hashicorp.expensereport.expense.domain;

import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

@Entity
public class ExpenseItem {

    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "id", columnDefinition = "BINARY(16)")
    private UUID id;

    private String name;

    @Column(name = "trip_id")
    private String tripId;

    private BigDecimal cost;

    private String currency;

    private Date date;

    private boolean reimbursable;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTripId() {
        return tripId;
    }

    public void setTripId(String tripId) {
        this.tripId = tripId;
    }

    public BigDecimal getCost() {
        return cost;
    }

    public void setCost(BigDecimal cost) {
        this.cost = cost;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public boolean isReimbursable() {
        return reimbursable;
    }

    public void setReimbursable(boolean reimbursable) {
        this.reimbursable = reimbursable;
    }

    @Override
    public String toString() {
        return "ExpenseItem{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", tripId='" + tripId + '\'' +
                ", cost=" + cost +
                ", currency='" + currency + '\'' +
                ", date=" + date +
                ", reimbursable=" + reimbursable +
                '}';
    }
}
