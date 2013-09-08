class SettingFormScreen < PM::GroupedTableScreen
  class AlertDelegator
    class Payment
      def self.execute
        if SKPaymentQueue.canMakePayments
          SKPaymentQueue.defaultQueue.addTransactionObserver(self)
          productIds = NSSet.setWithObject("1")
          skProductRequest = SKProductsRequest.alloc.initWithProductIdentifiers(productIds)
          skProductRequest.delegate = self
          skProductRequest.start
        end
      end

      def productsRequest(request, didReceiveResponse:response)
        if response
          response.invalidProductIdentifiers.each do |identifier|
            NSLog("invalid product identifier: %s" % identifier)
          end

          response.products.each do |product|
            NSLog("valid product identifier: %s" % product.productIdentifier)
            payment = SKPayment.paymentWithProduct(product)
            SKPaymentQueue.defaultQueue.addPayment(payment)
          end
        end
      end

      def paymentQueue(queue, updatedTransactions: transactions)
        purchasing = true
        transactions.each do |transaction|
          case transaction.transactionState
          when SKPaymentTransactionStatePurchasing
            NSLog("Payment Transaction Purchasing");
          when SKPaymentTransactionStatePurchased
            NSLog("Payment Transaction END Purchased: %s", transaction.transactionIdentifier)
            purchasing = false
            self.completeUpgradePlus
            queue.finishTransaction(transaction)
          when SKPaymentTransactionStateFailed
            NSLog("Payment Transaction END Failed: %s %s" % [transaction.transactionIdentifier, transaction.error])
            purchasing = false
            queue.finishTransaction(transaction)
          when SKPaymentTransactionStateRestored
            NSLog("Payment Transaction END Restored: %s" % transaction.transactionIdentifier)
            purchasing = false
            queue.finishTransaction(transaction)
          end
        end      

        unless purchasing
          PM.logger.error('fuck')
        end
      end

      def completeUpgradePlus
        PM.logger.info('happy!!!!!!!!!!!!!!')
      end
    end
  end
end
