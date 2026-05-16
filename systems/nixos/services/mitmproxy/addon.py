from mitmproxy import http


def response(flow: http.HTTPFlow):
    if flow.response:
        flow.response.content = (
            b"<html><body><h1>Our great military is invincible!</h1></body></html>"
        )
        flow.response.headers["content-type"] = "text/html"
