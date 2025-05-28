ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  content title: "Dashboard" do
    columns do
      # Left Column
      column do
        panel "Total Signups (Dairies)", class: "panel-signups" do
          div class: "metric" do
            total_signups = MyDairy.count
            h3 number_to_human(total_signups, units: { thousand: 'K', million: 'M', billion: 'B' })
          end
        end

        panel "Dairies on Free Trial", class: "panel-free-trial" do
          div class: "metric metric-with-button" do
            free_trial = MyDairy.joins(rechargs: :plan)
                                       .where("plans.name = 'Free Trail' AND rechargs.activated = 1 AND rechargs.expire_date >= ?", Time.now).uniq
            h3 number_to_human(free_trial.count, units: { thousand: 'K', million: 'M' })

            div do
              link_to "View Dairies", admin_my_dairies_path(q: { id_in: free_trial.pluck(:id) }), class: "button"
            end
          end
        end

        panel "Dairies with Active Plans", class: "panel-active-plans" do
          div class: "metric metric-with-button" do
            active_dairies = MyDairy.joins(rechargs: :plan)
                                           .where("rechargs.activated = 1 AND rechargs.expire_date >= ? AND plans.name != 'Free Trail'", Time.now)
                                           .uniq
            h3 number_to_human(active_dairies.count, units: { thousand: 'K', million: 'M' })
            div do
              link_to "View Dairies", admin_my_dairies_path(q: { id_in: active_dairies.pluck(:id) }), class: "button"
            end
          end
        end

        panel "Dairies Exiting After Free Trial", class: "panel-did-not-proceed" do
          div class: "metric metric-with-button" do
            non_proceeding_dairies = MyDairy.joins(rechargs: :plan)
                                                   .where("rechargs.expire_date < ? AND rechargs.activated = 1 AND plans.name = 'Free Trail'", Time.now)
                                                   .uniq
            h3 number_to_human(non_proceeding_dairies.count, units: { thousand: 'K', million: 'M' })
            div do
              link_to "View Dairies", admin_my_dairies_path(q: { id_in: non_proceeding_dairies.pluck(:id) }), class: "button"
            end
          end
        end

        panel "Dairies with Expired Plans", class: "panel-expired-plans" do
          div class: "metric metric-with-button" do
            expired_dairies = MyDairy.joins(rechargs: :plan)
                                      .where("plans.name != 'Free Trail'")
                                      .where("rechargs.activated = ? AND rechargs.expire_date < ?", 1, Time.now)
                                      .uniq
            h3 number_to_human(expired_dairies.count, units: { thousand: 'K', million: 'M' })
            div do
              link_to "View Dairies", admin_my_dairies_path(q: { id_in: expired_dairies.pluck(:id) }), class: "button"
            end
          end
        end
      end

      # Center Column
      column do
        panel "Total Transactions (Buy Milks)", class: "panel-total-transactions" do
          div class: "metric" do
            total_transactions = BuyMilk.count
            h3 number_to_human(total_transactions, units: { thousand: 'K', million: 'M' })
          end
        end

        panel "Weekly Transactions (Buy Milks)", class: "panel-total-transactions" do
          div class: "metric" do
            total_weekly_transactions = BuyMilk.where('created_at >= ?', 1.week.ago).count
            h3 number_to_human(total_weekly_transactions, units: { thousand: 'K', million: 'M' })
          end
        end

        panel "Dairies with Transactions", class: "panel-transactions-last" do
          div class: "metric" do
            [["1 Day", 1.day.ago], ["2 Days", 2.days.ago], ["3 Days", 3.days.ago], ["Last Week", 1.week.ago]].each do |label, time|
              dairies = MyDairy.joins(customers: :buy_milks).where('buy_milks.created_at >= ?', time)
              h4 do
                div class: "flex-container" do
                  span "#{label}: #{number_to_human(dairies.distinct.count)}"
                  span link_to("View", admin_my_dairies_path(q: { id_in: dairies.pluck(:id).uniq }), class: "button right-align")
                end
              end
            end
          end
        end
      end

      # Right Column
      column do
        panel "Monthly Revenue (Transactions)", class: "panel-monthly-revenue" do
          monthly_revenue = Recharg.joins(:plan)
                                    .where("plans.name != 'Free Trail'")
                                    .group_by_month(:created_at, last: 12)
                                    .sum('plans.amount')

          # Display monthly revenue in a table
          table_for monthly_revenue.to_a do |revenue|
            column "Month" do |(month, _amount)|
              month.strftime("%B %Y") if month
            end
            column "Revenue" do |(_month, amount)|
              number_to_currency(amount || 0, unit: '₹', format: "%u%n") # Display in Rupees
            end
          end

          # Total Monthly Revenue
          total_monthly_revenue = monthly_revenue.values.sum
          div class: "metric total-revenue" do
            h4 "Total Monthly Revenue: #{number_to_currency(total_monthly_revenue, unit: '₹', format: "%u%n")}"
          end
        end

        panel "Yearly Revenue (Transactions)", class: "panel-yearly-revenue" do
          yearly_revenue = Recharg.joins(:plan)
                                  .where("plans.name != 'Free Trail'")
                                  .group_by_year(:created_at)
                                  .sum('plans.amount')

          # Display yearly revenue in a table
          table_for yearly_revenue.to_a do |revenue|
            column "Year" do |(year, _amount)|
              year.strftime("%Y") if year
            end
            column "Revenue" do |(_year, amount)|
              number_to_currency(amount || 0, unit: '₹', format: "%u%n") # Display in Rupees
            end
          end

          # Total Yearly Revenue
          total_yearly_revenue = yearly_revenue.values.sum
          div class: "metric total-revenue" do
            h4 "Total Yearly Revenue: #{number_to_currency(total_yearly_revenue, unit: '₹', format: "%u%n")}"
          end
        end
      end
    end
  end
end
