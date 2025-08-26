1. Total Customers By City 

Select city, Count(customer_id) As Total_Customers
From customers
Group By city
Order By Total_Customers Desc;
________________________________________
2. Average Item Price By Category

Select category, Round(Avg(price),2) As Avg_Price
From menu_items
Group By category
Order By Avg_Price Desc;
________________________________________
3. Orders Placed Per Branch

Select branch_location, Count(order_id) As Total_Orders
From orders
Group By branch_location
Order By Total_Orders Desc;
________________________________________
4. Total Revenue Vs Pending Revenue

Select 
    Sum(Case When status = 'Paid' Then amount Else 0 End) As Paid_Revenue,
    Sum(Case When status = 'Pending' Then amount Else 0 End) As Pending_Revenue
From payments;
________________________________________
5. Top 5 Best Selling Items With Revenue

Select m.item_name, Sum(od.quantity) As Total_Sold, Round(Sum(od.quantity * m.price),2) As Total_Revenue
From order_details od
Join menu_items m On od.item_id = m.item_id
Group By m.item_name
Order By Total_Revenue Desc
Limit 5;
________________________________________
6. Category Share Of Total Sales 

Select category, 
       Sum(od.quantity * m.price) As Category_Revenue,
       Round(Sum(od.quantity * m.price) * 100.0 / Sum(Sum(od.quantity * m.price)) Over(), As Percent_Of_Total
From order_details od
Join menu_items m On od.item_id = m.item_id
Group By category
Order By Percent_Of_Total Desc;
________________________________________
7. Top Branch By Average Order Value

Select o.branch_location, Round(Avg(p.amount),2) As Avg_Order_Value
From orders o
Join payments p On o.order_id = p.order_id
Where p.status = 'Paid'
Group By o.branch_location
Order By Avg_Order_Value Desc;
________________________________________
8. Revenue Trend Last 6 Months (CTE)

Select 
    substr(order_date, 7, 4) || '-' || substr(order_date, 4, 2) As Month,
    Sum(p.amount) As Revenue
From orders o
Join payments p On o.order_id = p.order_id
Where p.status = 'Paid'
Group By Month
Order By Month Desc
Limit 6;
________________________________________
9. Most Loyal Customers (More Than 10 Orders)

Select c.name, Count(o.order_id) As Order_Count
From customers c
Join orders o On c.customer_id = o.customer_id
Group By c.customer_id
Having Order_Count > 10
Order By Order_Count Desc;
________________________________________
10. Best Performing Staff By Average Revenue Per Order

Select s.staff_name, Round(Avg(p.amount),2) As Avg_Revenue_Per_Order, Count(o.order_id) As Orders_Handled
From staff s
Join orders o On s.staff_id = o.staff_id
Join payments p On o.order_id = p.order_id
Where p.status = 'Paid'
Group By s.staff_id
Order By Avg_Revenue_Per_Order Desc
Limit 5;
________________________________________
11. Payment Method Share (Window Function)

Select payment_method, Count(*) As Total_Transactions,
       Round(Count(*) * 100.0 / Sum(Count(*)) Over(),2) As Percent_Of_Total
From payments
Group By payment_method
Order By Percent_Of_Total Desc;
________________________________________
12. Revenue Split By Payment Method & Branch

Select o.branch_location, p.payment_method, Sum(p.amount) As Revenue
From payments p
Join orders o On p.order_id = o.order_id
Where p.status = 'Paid'
Group By o.branch_location, p.payment_method
Order By o.branch_location, Revenue Desc;
________________________________________
13. Highest Spending Customer Each Branch 

Select 
    c.name,
    o.branch_location,
    Sum(p.amount) As Total_Spent
From customers c
Join orders o On c.customer_id = o.customer_id
Join payments p On o.order_id = p.order_id
Where p.status = 'Paid'
Group By c.customer_id, o.branch_location
Having Total_Spent = (
    Select Max(cs.Total_Spent)
    From (
        Select Sum(p2.amount) As Total_Spent
        From customers c2
        Join orders o2 On c2.customer_id = o2.customer_id
        Join payments p2 On o2.order_id = p2.order_id
        Where o2.branch_location = o.branch_location And p2.status = 'Paid'
        Group By c2.customer_id
    ) As cs
);
________________________________________
14. Customers Who Ordered Both Pizza And Dessert 

Select Distinct c.name
From customers c
Join orders o On c.customer_id = o.customer_id
Join order_details od On o.order_id = od.order_id
Join menu_items m On od.item_id = m.item_id
Where m.category = 'Pizza'
And c.customer_id In (
    Select c2.customer_id
    From customers c2
    Join orders o2 On c2.customer_id = o2.customer_id
    Join order_details od2 On o2.order_id = od2.order_id
    Join menu_items m2 On od2.item_id = m2.item_id
    Where m2.category = 'Dessert'
);
________________________________________
15. Most Popular Item Per Branch 

Select branch_location, item_name, Total_Sold
From (
    Select o.branch_location, m.item_name, Sum(od.quantity) As Total_Sold,
           Rank() Over (Partition By o.branch_location Order By Sum(od.quantity) Desc) As rnk
    From orders o
    Join order_details od On o.order_id = od.order_id
    Join menu_items m On od.item_id = m.item_id
    Group By o.branch_location, m.item_name
) t
Where rnk = 1;
________________________________________
16. Customers With Above Average Spending

Select c.name, Sum(p.amount) As Total_Spent
From customers c
Join orders o On c.customer_id = o.customer_id
Join payments p On o.order_id = p.order_id
Where p.status = 'Paid'
Group By c.customer_id
Having Total_Spent > (
    Select Avg(total) From (
        Select Sum(p2.amount) As total
        From orders o2
        Join payments p2 On o2.order_id = p2.order_id
        Where p2.status = 'Paid'
        Group By o2.customer_id
    )
);
________________________________________
17. Orders With Multiple Categories Inside One Order

Select o.order_id, Count(Distinct m.category) As Category_Count
From orders o
Join order_details od On o.order_id = od.order_id
Join menu_items m On od.item_id = m.item_id
Group By o.order_id
Having Category_Count > 2;
________________________________________
18. Staff Revenue Contribution Ranking

Select staff_name, Total_Revenue, 
       Rank() Over (Order By Total_Revenue Desc) As Revenue_Rank
From (
    Select s.staff_name, Sum(p.amount) As Total_Revenue
    From staff s
    Join orders o On s.staff_id = o.staff_id
    Join payments p On o.order_id = p.order_id
    Where p.status = 'Paid'
    Group By s.staff_id
);

