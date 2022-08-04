;; TODO a simple translation thingy.
(fn query-translation-api [api-key]
  (let [headers {:Ocp-Apim-Subscription-Key api-key
                 :Ocp-Apim-Subscription-Region :global
                 :Content-Type :application/json}]
    (fn [text]
      (hs.http.asyncPost "https://api.cognitive.microsofttranslator.com//dictionary/lookup?api-version=3.0&from=en&to=de"
                         (.. "[{'Text': '" text "'}]") headers
                         (fn [code body header]
                           (do
                             (print (fennel.view body))
                             (alert body)))))))

(query-translation-api :flower)

{: query-translation-api}

