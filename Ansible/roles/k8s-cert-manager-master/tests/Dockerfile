FROM alpine:3.7

RUN apk add --no-cache ansible

RUN mkdir -p /build/roles
COPY roles/* /build/roles/
RUN echo "localhost" > /build/inventory
# For now...
RUN ansible-playbook -i /build/inventory /build/roles/k8s-cert-manager/tests/k8s-cert-manager-test.yml -c local
