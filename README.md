# flutter-workflow-prototype
The goal is to build a prototype mobile app using Flutter that simulates a real-world request and confirmation workflow.
The app must support two roles
with distinct functionalities:
● End User → Submits requests containing multiple items.
● Receiver → Reviews requests and confirms the availability of items one by one.

The system must track request statuses (Pending, Confirmed, Partially Fulfilled) and handle
partial confirmations by reassigning unconfirmed items.

Roles & Features
1. End User

This is the person who requests multiple items.
They can:

Create a new request by selecting the items they need.

Submit that request to the system.

Check the status of their requests, which could be:

Pending → The request has been submitted and is waiting for review.

Confirmed → All items were approved by the receiver.

Partially Fulfilled → Some items were confirmed, but others got reassigned.

Follow the progress of their requests in real-time (without relying on Firebase).

2. Receiver

This is the person or team responsible for reviewing and fulfilling requests.
They can:

See all new requests assigned to them.

Open a request and review each item one by one.

Mark items as either Available or Not Available.

Submit their decisions back to the system.

If everything is confirmed → the request status updates to Confirmed.

If only some items are confirmed → the request status changes to Partially Fulfilled, and the unconfirmed items are reassigned.


