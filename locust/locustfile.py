import time
from locust import HttpUser, task, between


class ReportUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def get_report_for_trip(self):
        self.client.get(
            f"/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa")
        time.sleep(1)
