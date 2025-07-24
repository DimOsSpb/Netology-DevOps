FROM hashicorp/terraform:latest AS ter
FROM scratch
COPY --from=ter /bin/terraform /