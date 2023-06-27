import React from "react";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";

function Footer() {
  const year = new Date().getFullYear();

  return (
    <div id="footer">
      <footer>
        <Container fluid="md">
          <Row>
            <Col>
              <p>
                The Internet Computer's largest digital marketplace for crypto
                collectibles and non-fungible tokens (NFTs). Buy, sell, and
                discover exclusive digital items.
              </p>
            </Col>
            <Col>
              <p>Copyright ⓒ {year} | Created by <a href="https://github.com/brunsoares">@BrunSoares</a></p>
            </Col>
          </Row>
        </Container>
      </footer>
    </div>
  );
}

export default Footer;
