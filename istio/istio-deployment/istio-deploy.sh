#! /bin/bash

# Variable declarations
ISTIO_VERSION=${3:-"1.20.2"}
ISTIO_PATH=$(pwd)/istio-$ISTIO_VERSION/bin

# Set exit if error
set -e
    # Evaluate command that will be executed
    if [ $1 != "install" ] && [ $1 != "upgrade" ];
    then
        echo "Please put the command either 'install' or 'upgrade'"
        exit 1
    fi

    kube_context="gke_fade-rosyad-project_us-central1_gke-fade-rosyad"


    # Download Istioctl if not exist
    if [ ! -f $ISTIO_PATH/istioctl ];
    then
        echo "Istioctl does not exist, will download first..."
        curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
    fi

echo "Executing Istio $1"
$ISTIO_PATH/istioctl x precheck --context $kube_context
$ISTIO_PATH/istioctl $1 --context $kube_context -f $(pwd)/istio-operator.yaml -y
kubectl --context $kube_context label namespace default istio-injection=enabled
